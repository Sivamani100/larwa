// lib/core/constants.dart

class AppConstants {
  // ─── Backend ─────────────────────────────────────────────────
  static const String backendUrl = 'https://web-production-1eb90.up.railway.app';

  // ─── Supabase ────────────────────────────────────────────────
  static const String supabaseUrl = 'https://zualzifhftvixpfrcjqa.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1YWx6aWZoZnR2aXhwZnJjanFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI0ODg1NTAsImV4cCI6MjA4ODA2NDU1MH0.xNjd9EYLITrgYVz0kGGA4cI3AoK258RaZSHqqPO7yGM';

  // ─── Deepgram ────────────────────────────────────────────────
  static const String deepgramApiKey = 'bcd33a355a883ea11478878e20e690914056ece0';

  // ─── ElevenLabs ──────────────────────────────────────────────
  static const String elevenLabsApiKey = 'sk_7e53229591e0828f7ceafbbc1810f41cbb39f5215c50a461';
  static const String elevenLabsVoiceId = '21m00Tcm4TlvDq8ikWAM';

  // ─── Owner ───────────────────────────────────────────────────
  static const String ownerName = 'Satya'; // Updated per Version 4.0 Plan

  // ─── Colours (hex values) ────────────────────────────────────
  static const int colorBackground = 0xFF0F1117;
  static const int colorCardBg = 0xFF1A1D2E;
  static const int colorPrimary = 0xFF4A90D9;
  static const int colorSuccess = 0xFF2ECC71;
  static const int colorWarning = 0xFFF39C12;
  static const int colorUrgent = 0xFFE74C3C;
  static const int colorTextPrimary = 0xFFFFFFFF;
  static const int colorTextSecondary = 0xFF8A8F9C;
  static const int colorSurface = 0xFF252836;

  // ─── Method Channels ─────────────────────────────────────────
  static const String callControlChannel = 'com.larwa.larwa/call_control';
  static const String audioStreamChannel = 'com.larwa.larwa/audio_stream';
}
