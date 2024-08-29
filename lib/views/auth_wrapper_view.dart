import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_chat/views/chat_view.dart';
import 'package:supabase_chat/providers/auth_provider.dart';

class AuthWrapperView extends HookConsumerWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);

    var displayName = useState('');
    var isSigningIn = useState(false);

    if (currentUser != null) {
      return const HomeView();
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GUESS ME',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),

              const SizedBox(height: 30),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter a nickname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                ),
                onChanged: (it) => displayName.value = it.trim(),
              ),

              //
              const SizedBox(height: 30),
              //

              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  disabledForegroundColor: Colors.grey[200],
                  disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                onPressed: displayName.value.isEmpty
                    ? null
                    : () async {
                        isSigningIn.value = true;

                        await ref.read(authProvider.notifier).signInAnonymously(displayName.value);

                        isSigningIn.value = false;
                      },
                child: Visibility(
                  visible: !isSigningIn.value,
                  replacement: const CircularProgressIndicator(),
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
