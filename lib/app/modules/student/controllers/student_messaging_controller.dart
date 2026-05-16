import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';
import '../../../services/student_messaging_service.dart';
import '../../../data/models/messaging/message_model.dart';
import '../../../data/models/messaging/conversation_model.dart';

class StudentMessagingController extends GetxController {
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();
  final _messagingService = Get.find<StudentMessagingService>();

  final inbox = <ConversationModel>[].obs;
  final activeMessages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final isOffline = false.obs;

  final messageInputController = TextEditingController();
  final scrollController = ScrollController();

  final activeConversation = Rxn<ConversationModel>();

  String get _studentId => _authService.session.value?.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (offline) => isOffline.value = offline);
    loadInbox();
  }

  Future<void> loadInbox() async {
    try {
      isLoading.value = true;
      final studentId = _studentId;
      if (studentId.isEmpty) return;

      final conversations = await _messagingService.getInbox(studentId);
      inbox.assignAll(conversations);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load inbox');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openConversation(ConversationModel chat) async {
    activeConversation.value = chat;
    await _loadMessages(chat.participantId);
    await _messagingService.markAsRead(_studentId, chat.participantId);
    loadInbox();
  }

  Future<void> _loadMessages(String participantId) async {
    final messages = await _messagingService.getConversation(
      _studentId,
      participantId,
    );
    activeMessages.assignAll(messages);
    _scrollToBottom();
  }

  Future<void> sendMessage() async {
    final content = messageInputController.text.trim();
    if (content.isEmpty || activeConversation.value == null) return;

    final participantId = activeConversation.value!.participantId;
    messageInputController.clear();

    await _messagingService.sendMessage(
      _studentId,
      participantId,
      content,
      isOffline: isOffline.value,
    );
    await _loadMessages(participantId);
    loadInbox();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageInputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
