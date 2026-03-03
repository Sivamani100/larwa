package com.larwa.larwa

import android.telecom.Call
import android.telecom.CallScreeningService
import android.content.Context

class AiCallScreeningService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val prefs = getSharedPreferences("AiCallPrefs", Context.MODE_PRIVATE)
        val aiModeOn = prefs.getBoolean("ai_mode_enabled", false)
        val vipCsv = prefs.getString("vip_numbers", "") ?: ""
        val blockedCsv = prefs.getString("blocked_numbers", "") ?: ""

        val number = callDetails.handle?.schemeSpecificPart ?: ""
        val normalized = normalizeNumber(number)
        val vipSet = vipCsv.split(',').map { it.trim() }.filter { it.isNotEmpty() }.toSet()
        val isVip = normalized.isNotEmpty() && vipSet.contains(normalized)

        val blockedSet = blockedCsv.split(',').map { it.trim() }.filter { it.isNotEmpty() }.toSet()
        val isBlocked = normalized.isNotEmpty() && blockedSet.contains(normalized)

        val response = CallResponse.Builder()

        if (callDetails.callDirection == Call.Details.DIRECTION_INCOMING && isBlocked) {
            response
                .setDisallowCall(true)
                .setRejectCall(false)
                .setSilenceCall(true)
                .setSkipCallLog(false)
                .setSkipNotification(true)
            respondToCall(callDetails, response.build())
            return
        }

        if (aiModeOn && callDetails.callDirection == Call.Details.DIRECTION_INCOMING) {
            if (isVip) {
                // VIP BYPASS: let the phone behave normally
                response
                    .setDisallowCall(false)
                    .setRejectCall(false)
                    .setSilenceCall(false)
                    .setSkipCallLog(false)
                    .setSkipNotification(false)
                respondToCall(callDetails, response.build())
                return
            }

            if (AiInCallService.isAiHandlingCall) {
                // Concurrent call policy: reject second call while AI is busy
                response
                    .setDisallowCall(false)
                    .setRejectCall(true)
                    .setSilenceCall(true)
                    .setSkipCallLog(false)
                    .setSkipNotification(true)
                respondToCall(callDetails, response.build())
                return
            }

            // AI MODE IS ON — silence everything, let InCallService handle it
            response
                .setDisallowCall(false)      // Don't block — we want to answer it
                .setRejectCall(false)         // Don't reject
                .setSilenceCall(true)         // CRITICAL: no ring, no vibration
                .setSkipCallLog(false)        // Keep in call log
                .setSkipNotification(true)    // CRITICAL: no incoming call screen
        } else {
            // AI MODE IS OFF — let call ring normally
            response
                .setDisallowCall(false)
                .setRejectCall(false)
                .setSilenceCall(false)
                .setSkipCallLog(false)
                .setSkipNotification(false)
        }

        respondToCall(callDetails, response.build())
    }

    private fun normalizeNumber(raw: String): String {
        if (raw.isBlank()) return ""
        val hasPlus = raw.trim().startsWith("+")
        val digits = raw.replace(Regex("[^\\d]"), "")
        if (digits.isBlank()) return ""
        return if (hasPlus) "+$digits" else "+$digits"
    }
}
