import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_messaging_controller.dart';
import '../../../data/models/messaging/message_model.dart';

class StudentChatView extends GetView<StudentMessagingController> {
  const StudentChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildOfflineBanner(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final chat = controller.activeConversation.value;
        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.cardDark,
              child: Text(
                chat?.participantName.isNotEmpty == true
                    ? chat!.participantName.substring(0, 1)
                    : '?',
                style: const TextStyle(
                  color: AppColors.accentLime,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat?.participantName ?? 'Chat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  chat?.participantRole.name.toUpperCase() ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOfflineBanner() {
    return Obx(() {
      if (!controller.isOffline.value) return const SizedBox();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.orangeAccent.withValues(alpha: 0.1),
        child: const Center(
          child: Text(
            'Offline Mode - Messages will be queued',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMessageList() {
    return Obx(() {
      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: controller.activeMessages.length,
        itemBuilder: (context, index) {
          final msg = controller.activeMessages[index];
          // Determine if message is from the current student user
          final isMe =
              msg.senderId !=
              controller.activeConversation.value?.participantId;
          return _buildChatBubble(msg, isMe);
        },
      );
    });
  }

  Widget _buildChatBubble(MessageModel msg, bool isMe) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.accentLime.withValues(alpha: 0.1)
                : AppColors.cardDark,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 20),
            ),
            border: Border.all(
              color: isMe
                  ? AppColors.accentLime.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            msg.content,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        _buildBubbleFooter(msg, isMe),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBubbleFooter(MessageModel msg, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Text(
          DateFormat('hh:mm a').format(msg.timestamp),
          style: const TextStyle(color: Colors.white24, fontSize: 10),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            msg.isRead ? Icons.done_all : Icons.done,
            size: 12,
            color: msg.isRead ? AppColors.accentLime : Colors.white24,
          ),
        ],
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageInputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => controller.sendMessage(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.accentLime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
