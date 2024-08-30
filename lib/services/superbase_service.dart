import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_chat/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final superbaseServiceProvider = Provider<SuperbaseService>((ref) {
  return SuperbaseService();
});

class SuperbaseService {
  SuperbaseService();

  final client = Supabase.instance.client;
  final authClient = Supabase.instance.client.auth;
  final storageClient = Supabase.instance.client.storage;

  User? getUser() {
    return authClient.currentUser;
  }

  Future<bool> signInAnonymously(String displayName) async {
    final response = await authClient.signInAnonymously(
      data: {
        'displayName': displayName,
      },
    );

    if (response.user != null) {
      return true;
    }

    return false;
  }

  Future<String> uploadImage(File imageFile) async {
    final uniqueId = const Uuid().v4();

    final storagePath = await storageClient.from(kChatMediaBucket).upload(
          '$uniqueId.png',
          imageFile,
          fileOptions: const FileOptions(upsert: false),
        );

    return storagePath;
  }
}
