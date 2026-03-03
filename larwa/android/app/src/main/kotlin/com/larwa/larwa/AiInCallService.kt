package com.larwa.larwa

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.speech.tts.TextToSpeech
import android.telecom.Call
import android.telecom.InCallService
import android.telecom.VideoProfile
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.util.Locale

class AiInCallService : InCallService() {

    companion object {
        var instance: AiInCallService? = null
        var audioEventSink: EventChannel.EventSink? = null
        @Volatile
        var isAiHandlingCall: Boolean = false
        private const val CHANNEL_ID = "LarwaActiveCall"
        private const val NOTIFICATION_ID = 888
    }

    private var activeCall: Call? = null
    private var audioRecord: AudioRecord? = null
    private var audioTrack: AudioTrack? = null
    private var tts: TextToSpeech? = null
    private var recordingJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private val SAMPLE_RATE = 16000
    private val CHANNEL_IN  = AudioFormat.CHANNEL_IN_MONO
    private val CHANNEL_OUT = AudioFormat.CHANNEL_OUT_MONO
    private val ENCODING    = AudioFormat.ENCODING_PCM_16BIT

    override fun onCreate() {
        super.onCreate()
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                try {
                    tts?.language = Locale.US
                    tts?.setSpeechRate(1.0f)
                } catch (_: Exception) {}
            }
        }
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        instance = this

        val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("ai_mode_enabled", false)) return

        activeCall = call
        isAiHandlingCall = true

        scope.launch {
            delay(400)
            withContext(Dispatchers.Main) {
                answerCallSilently(call)
            }
            delay(600)
            setupAudio()
            startAudioCapture()
            
            // Send call started event to Flutter
            withContext(Dispatchers.Main) {
                val callerNumber = call.details.handle.schemeSpecificPart
                audioEventSink?.success(mapOf("event" to "call_started", "number" to callerNumber))
            }
        }
    }

    private fun setupAudio() {
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        am.mode = AudioManager.MODE_IN_COMMUNICATION
        am.isSpeakerphoneOn = true
        try {
            @Suppress("DEPRECATION")
            am.isMicrophoneMute = true
        } catch (_: Exception) {}
    }

    private fun startAudioCapture() {
        val bufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_IN, ENCODING)
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
            return
        }
        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.VOICE_COMMUNICATION,
            SAMPLE_RATE, CHANNEL_IN, ENCODING,
            bufferSize * 4
        )
        audioRecord?.startRecording()
        recordingJob = scope.launch {
            val buffer = ByteArray(bufferSize)
            while (isActive && audioRecord?.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                if (bytesRead > 0) {
                    withContext(Dispatchers.Main) {
                        audioEventSink?.success(buffer.copyOf(bytesRead))
                    }
                }
            }
        }
    }

    fun playAudioToCall(pcmBytes: ByteArray) {
        scope.launch {
            if (audioTrack == null) {
                val bufferSize = AudioTrack.getMinBufferSize(SAMPLE_RATE, CHANNEL_OUT, ENCODING)
                audioTrack = AudioTrack.Builder()
                    .setAudioAttributes(AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build())
                    .setAudioFormat(AudioFormat.Builder()
                        .setEncoding(ENCODING)
                        .setSampleRate(SAMPLE_RATE)
                        .setChannelMask(CHANNEL_OUT)
                        .build())
                    .setTransferMode(AudioTrack.MODE_STREAM)
                    .setBufferSizeInBytes(bufferSize * 4)
                    .build()
                audioTrack?.play()
            }
            audioTrack?.write(pcmBytes, 0, pcmBytes.size)
        }
    }

    fun speakText(text: String) {
        try {
            val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            am.mode = AudioManager.MODE_IN_COMMUNICATION
            am.isSpeakerphoneOn = true
        } catch (_: Exception) {}

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                tts?.speak(text, TextToSpeech.QUEUE_ADD, null, "larwa_${System.currentTimeMillis()}")
            } else {
                @Suppress("DEPRECATION")
                tts?.speak(text, TextToSpeech.QUEUE_ADD, null)
            }
        } catch (_: Exception) {}
    }

    fun endCall() {
        activeCall?.disconnect()
    }

    private fun answerCallSilently(call: Call) {
        // Create Notification Channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Larwa Active Call",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Larwa AI Assistant")
            .setContentText("AI is handling an active call...")
            .setSmallIcon(android.`R`.drawable.stat_sys_phone_call)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            startForeground(NOTIFICATION_ID, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        call.answer(VideoProfile.STATE_AUDIO_ONLY)
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        cleanup()
        stopForeground(true)
        scope.launch(Dispatchers.Main) {
            audioEventSink?.success(mapOf("event" to "call_ended"))
        }
        instance = null
        isAiHandlingCall = false
    }

    private fun cleanup() {
        recordingJob?.cancel()
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (e: Exception) {}
        audioRecord = null
        
        try {
            audioTrack?.stop()
            audioTrack?.release()
        } catch (e: Exception) {}
        audioTrack = null

        try {
            tts?.stop()
        } catch (_: Exception) {}
        
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        try {
            @Suppress("DEPRECATION")
            am.isMicrophoneMute = false
        } catch (_: Exception) {}
        am.mode = AudioManager.MODE_NORMAL
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            tts?.shutdown()
        } catch (_: Exception) {}
        tts = null
    }
}
