package com.larwa.larwa

import android.content.Intent
import android.telecom.TelecomManager
import android.app.role.RoleManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private val CALL_CONTROL_CHANNEL = "com.larwa.larwa/call_control"
    private val AUDIO_STREAM_CHANNEL = "com.larwa.larwa/audio_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Call Control Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestRole" -> requestDialerRole(result)
                "isRoleHeld" -> {
                    val rm = getSystemService(Context.ROLE_SERVICE) as RoleManager
                    result.success(rm.isRoleHeld(RoleManager.ROLE_DIALER))
                }
                "getAiMode" -> {
                    val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
                    result.success(prefs.getBoolean("ai_mode_enabled", false))
                }
                "getVipNumbers" -> {
                    val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
                    val vipCsv = prefs.getString("vip_numbers", "") ?: ""
                    result.success(
                        vipCsv.split(',').map { it.trim() }.filter { it.isNotEmpty() }
                    )
                }
                "setVipNumbers" -> {
                    val list = call.arguments as? List<*>
                    val vipCsv = list?.joinToString(",") { it?.toString()?.trim().orEmpty() }
                        ?.split(',')
                        ?.map { it.trim() }
                        ?.filter { it.isNotEmpty() }
                        ?.distinct()
                        ?.joinToString(",")
                        ?: ""
                    val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
                    prefs.edit().putString("vip_numbers", vipCsv).apply()
                    result.success(null)
                }
                "getBlockedNumbers" -> {
                    val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
                    val blockedCsv = prefs.getString("blocked_numbers", "") ?: ""
                    result.success(
                        blockedCsv.split(',').map { it.trim() }.filter { it.isNotEmpty() }
                    )
                }
                "setBlockedNumbers" -> {
                    val list = call.arguments as? List<*>
                    val blockedCsv = list?.joinToString(",") { it?.toString()?.trim().orEmpty() }
                        ?.split(',')
                        ?.map { it.trim() }
                        ?.filter { it.isNotEmpty() }
                        ?.distinct()
                        ?.joinToString(",")
                        ?: ""
                    val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
                    prefs.edit().putString("blocked_numbers", blockedCsv).apply()
                    result.success(null)
                }
                "endCall" -> {
                    AiInCallService.instance?.endCall()
                    result.success(null)
                }
                "playAudio" -> {
                    val pcmBytes = call.arguments as? ByteArray
                    if (pcmBytes != null) {
                        AiInCallService.instance?.playAudioToCall(pcmBytes)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "PCM bytes missing", null)
                    }
                }
                "speakText" -> {
                    val text = call.arguments as? String
                    if (!text.isNullOrBlank()) {
                        AiInCallService.instance?.speakText(text)
                    }
                    result.success(null)
                }
                "toggleAiMode" -> {
                    val enabled = call.arguments as? Boolean ?: false
                    val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("ai_mode_enabled", enabled).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Audio Stream Event Channel (Kotlin -> Flutter)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    AiInCallService.audioEventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    AiInCallService.audioEventSink = null
                }
            }
        )
    }

    private fun requestDialerRole(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (roleManager.isRoleAvailable(RoleManager.ROLE_DIALER)) {
                if (roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
                    result.success(true)
                } else {
                    val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                    startActivityForResult(intent, 101)
                    // Result will be handled async, but we return true to indicate intent started
                    result.success(false) 
                }
            } else {
                result.error("ROLE_UNAVAILABLE", "Dialer role not available on this device", null)
            }
        } else {
            // Pre-Q handled by TelecomManager.ACTION_CHANGE_DEFAULT_DIALER
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, 101)
            result.success(false)
        }
    }
}
