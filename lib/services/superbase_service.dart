import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final superbaseServiceProvider = Provider<SuperbaseService>((ref) {
  return SuperbaseService();
});

class SuperbaseService {
  SuperbaseService();

  // TODO: setup clients

  Future<bool> signInAnonymously(String displayName) async {
    // TODO: Implement the sign-in anonymously method
    return false;
  }

  Future<String> uploadImage(File imageFile) async {
    // TODO: implement supabase upload method

    return '';
  }
}
