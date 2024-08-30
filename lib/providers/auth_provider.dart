import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_chat/services/superbase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthProvider, User?>(
  (ref) {
    final superbaseService = ref.watch(superbaseServiceProvider);

    return AuthProvider(superbaseService);
  },
);

class AuthProvider extends StateNotifier<User?> {
  AuthProvider(this.superbaseService) : super(null) {
    checkIfUserExists();
  }

  final SuperbaseService superbaseService;

  User? _currentUser;
  User? get currentUser => _currentUser;

  void checkIfUserExists() async {}

  Future<void> signInAnonymously(String displayName) async {
    final isSignedIn = await superbaseService.signInAnonymously(displayName);

    if (isSignedIn) {
      state = superbaseService.getUser();
    }
  }
}
