import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/values/constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString customApiKey = ''.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  ChatSession? _chatSession;
  GenerativeModel? _model;

  String get activeApiKey {
    if (customApiKey.value.isNotEmpty) {
      return customApiKey.value;
    }
    return AppConstants.geminiApiKey;
  }

  bool get hasApiKey => activeApiKey.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeChatSession();

    // Add a welcome message if the conversation is empty
    if (messages.isEmpty) {
      messages.add(
        ChatMessage(text: "Hi! I'm Gemini. How can I help you today?", isUser: false, timestamp: DateTime.now()),
      );
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initializeChatSession() {
    final key = activeApiKey;
    if (key.isEmpty) {
      _model = null;
      _chatSession = null;
      return;
    }

    try {
      _model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: key);
      // We can pre-populate the session history with previous messages if we want,
      // but starting a clean session is simpler. We will build the session history
      // from the existing messages.
      final history = messages
          .where((m) => m.timestamp != messages.first.timestamp) // Skip the welcome message
          .map((m) {
            if (m.isUser) {
              return Content.text(m.text);
            } else {
              return Content.model([TextPart(m.text)]);
            }
          })
          .toList();

      _chatSession = _model!.startChat(history: history);
    } catch (e) {
      debugPrint('Error initializing Gemini model: $e');
    }
  }

  void setCustomApiKey(String key) {
    customApiKey.value = key.trim();
    _initializeChatSession();

    Get.snackbar(
      'API Key Updated',
      key.isEmpty ? 'Using key from environment configuration.' : 'Successfully saved custom API key for this session.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    if (!hasApiKey) {
      Get.snackbar(
        'API Key Required',
        'Please configure your Gemini API Key first by clicking the Settings icon at the top.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Add user message to UI
    final userMessage = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    messages.add(userMessage);
    textController.clear();
    _scrollToBottom();

    // Start loading state
    isLoading.value = true;

    try {
      // Reinitialize if session got lost or wasn't set up
      if (_chatSession == null) {
        _initializeChatSession();
      }

      if (_chatSession == null) {
        throw Exception("Could not establish chat session. Check your API key.");
      }

      // Call API
      final response = await _chatSession!.sendMessage(Content.text(text));
      final responseText = response.text ?? 'No response text received.';

      // Add Gemini message to UI
      messages.add(ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now()));
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      messages.add(
        ChatMessage(
          text:
              'Sorry, I encountered an error: ${e.toString()}\n\nPlease verify that your API key is valid and you have active quota limits.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void clearChat() {
    messages.clear();
    messages.add(
      ChatMessage(text: "Conversation cleared. How can I help you now?", isUser: false, timestamp: DateTime.now()),
    );
    _initializeChatSession();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
