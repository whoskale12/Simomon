import 'package:flutter/services.dart';

import './services/user_profile_service.dart';
import 'core/app_export.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load profile and transactions before app starts
  final profileService = UserProfileService();
  await profileService.loadFromPrefs();

  final txService = TransactionService();
  await txService.loadTransactions();

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Flutter error: ${details.exception}');
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(const Duration(seconds: 5), () {
        hasShownError = false;
      });
      return _SafeErrorWidget(message: details.exception.toString());
    }
    return const SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider<TransactionService>.value(
      value: txService,
      child: MyApp(profileService: profileService),
    ),
  );
}

class _SafeErrorWidget extends StatelessWidget {
  final String message;
  const _SafeErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F3FF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF7C4DFF),
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Terjadi kesalahan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1035),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba kembali ke halaman sebelumnya',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final UserProfileService profileService;

  const MyApp({super.key, required this.profileService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.profileService.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    widget.profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Simomon',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.profileService.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }
}
