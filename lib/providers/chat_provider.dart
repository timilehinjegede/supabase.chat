import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_chat/models/chat_message.dart';
import 'package:supabase_chat/services/superbase_service.dart';

final chatProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  final superbaseService = ref.watch(superbaseServiceProvider);

  return ChatProvider(superbaseService);
});

class ChatProvider extends ChangeNotifier {
  ChatProvider(this.superbaseService);

  final SuperbaseService superbaseService;

  Future<void> sendMessage(ChatMessage message, {File? attachment}) async {
    if (attachment != null && attachment.existsSync()) {
      final imageUrl = await superbaseService.uploadImage(attachment);
      message = message.copyWith(imagePath: imageUrl);
    }

    // TODO: add the message to the table just created
  }
}