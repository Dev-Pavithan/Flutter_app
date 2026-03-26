import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'pwa_interop.dart';
import 'screens/dashboard_wrapper.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(AttendanceApp(prefs: prefs));
}

class AttendanceApp extends StatelessWidget {
  final SharedPreferences prefs;
  const AttendanceApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WSTSC Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: SplashGate(prefs: prefs),
    );
  }
}

class SplashGate extends StatefulWidget {
  final SharedPreferences prefs;
  const SplashGate( {super.key, required this.prefs});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    final bool isLoggedIn = widget.prefs.getBool('isLoggedIn') ?? false;
    
    // Smooth check
    await Future.delayed(const Duration(milliseconds: 500)); 

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardWrapper()),
      );
    } else {
      // Direct navigation to Login
      // LoginScreen will handle the popup if not installed
      bool installed = true;
      if (kIsWeb) {
        installed = isPWAInstalled();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(showInstallPrompt: !installed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.school_rounded, size: 80, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
