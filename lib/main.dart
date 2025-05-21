import 'package:flutter/material.dart';
import 'package:flutter_community_app/routes/router.dart';
import 'package:flutter_community_app/services/supabase_service.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_community_app/providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with correct credentials
  await SupabaseService.initialize(
    // Replace with your actual Supabase URL and anon key from your Supabase dashboard
    supabaseUrl: 'https://prepugondsejhpzzhygj.supabase.co',
    supabaseKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByZXB1Z29uZHNlamhwenpoeWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NzYwNzksImV4cCI6MjA2MzM1MjA3OX0.njftTyuIqdlx8TetNFtPWVd6unbO9SesnYPTVmW28gw',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(routerProvider);
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'Campus Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
