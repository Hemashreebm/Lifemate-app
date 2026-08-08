import 'dart:async';
import 'gemini_service.dart';

/// Central AI Assistant Service for Lifemate v2.0.
/// Delegates prompt generation to GeminiService (Secure Backend / Local Dev Key / Context Fallback).
class AiAssistantService {
  static final AiAssistantService instance = AiAssistantService._();
  AiAssistantService._();

  /// Send prompt to AI engine and return generated response.
  Future<String> sendMessage(String prompt) async {
    return GeminiService.instance.generateResponse(prompt);
  }
}
