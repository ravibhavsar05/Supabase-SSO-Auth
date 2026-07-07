import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Get.back()),
        title: Row(
          children: [
            // Gemini-like sparkling icon
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.googleBlue, Colors.purpleAccent, AppColors.googleRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(Icons.auto_awesome, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Gemini AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_suggest_rounded),
            tooltip: 'Configure API Key',
            onPressed: () => _showApiKeyDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear Chat',
            onPressed: () => _showClearConfirmation(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Informative banner if API key is missing
          Obx(() {
            if (!controller.hasApiKey) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.googleRed.withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.googleRed.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.googleRed, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'API Key Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gemini AI requires an API Key. You can generate a FREE key from Google AI Studio and configure it here.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showApiKeyDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.googleBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.key_rounded, size: 14),
                          label: const Text('Enter Key', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _launchApiKeyUrl(),
                          child: const Text(
                            'Get Free Key',
                            style: TextStyle(color: AppColors.googleBlue, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Chat Messages List
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: controller.messages.length + (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return _buildTypingIndicatorRow(isDark);
                  }
                  final msg = controller.messages[index];
                  return _buildMessageRow(context, msg, isDark);
                },
              );
            }),
          ),

          // Message Input Field
          _buildInputBar(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageRow(BuildContext context, ChatMessage msg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8.0, top: 4.0),
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
                shape: BoxShape.circle,
              ),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(colors: [AppColors.googleBlue, Colors.purpleAccent]).createShader(bounds),
                child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? (isDark ? AppColors.googleBlue.withOpacity(0.2) : AppColors.googleBlue.withOpacity(0.1))
                    : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                border: Border.all(
                  color: msg.isUser
                      ? AppColors.googleBlue.withOpacity(0.3)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                ),
                boxShadow: [
                  if (!msg.isUser)
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.05 : 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    msg.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(msg.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: msg.text));
                          Get.snackbar(
                            'Copied to Clipboard',
                            'Message text has been copied.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                            colorText: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            borderColor: AppColors.googleBlue.withOpacity(0.3),
                            borderWidth: 1,
                            margin: const EdgeInsets.all(12),
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cardLight,
              child: Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicatorRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0, top: 4.0),
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
              shape: BoxShape.circle,
            ),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(colors: [AppColors.googleBlue, Colors.purpleAccent]).createShader(bounds),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TypingIndicator()]),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontSize: 15,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ask Gemini...',
                          hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final isLoading = controller.isLoading.value;
              return Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.googleBlue, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: isLoading ? null : () => controller.sendMessage(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final tempController = TextEditingController(text: controller.customApiKey.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.key_rounded, color: AppColors.googleBlue),
              const SizedBox(width: 10),
              Text(
                'Configure Gemini API Key',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Input your custom API key. It will be stored securely in memory for this session.',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tempController,
                obscureText: true,
                style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                decoration: InputDecoration(
                  labelText: 'API Key',
                  labelStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  hintText: 'AIzaSy...',
                  hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.googleBlue, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    tooltip: 'Get Key from AI Studio',
                    onPressed: () => _launchApiKeyUrl(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Alternatively, define GEMINI_API_KEY in your local .env file to persist it across sessions.',
                style: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.setCustomApiKey(tempController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.googleBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Clear Conversation?',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This will clear your active chat history. The AI will forget the context of this conversation.',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.clearChat();
                Navigator.pop(context);
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchApiKeyUrl() async {
    final url = Uri.parse('https://aistudio.google.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final double value = (1.0 - ((_controller.value - delay) % 1.0)).clamp(0.0, 1.0);
            final double scale = 0.6 + (0.4 * value);
            final double opacity = 0.3 + (0.7 * value);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.googleBlue, shape: BoxShape.circle),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
