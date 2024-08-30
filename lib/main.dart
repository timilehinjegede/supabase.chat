import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_chat/views/auth_wrapper_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 
  await Supabase.initialize(
    url: 'https://bymdhkhghrxrdeqfmxpi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5bWRoa2hnaHJ4cmRlcWZteHBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ5NTUxNjksImV4cCI6MjA0MDUzMTE2OX0.dxeBD5jec02k9NASU1fkNwcpwb-ISLi0xbcYWf0gfz4',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const AuthWrapperView(),
    );
  }
}
