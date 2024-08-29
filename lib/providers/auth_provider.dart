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
    // TODO: check user session after successful sign in
  }

  final SuperbaseService superbaseService;

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> signInAnonymously(String displayName) async {
    final isSignedIn = await superbaseService.signInAnonymously(displayName);

    // TODO: check if loggined in
    if (isSignedIn) {}
  }
}
