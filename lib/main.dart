import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'pwa_interop.dart';
import 'screens/dashboard_wrapper.dart';
import 'screens/login_screen.dart';

// Global theme notifier for easy switching
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  // Load saved theme preference
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? true;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(AttendanceApp(prefs: prefs));
}

class AttendanceApp extends StatelessWidget {
  final SharedPreferences prefs;
  const AttendanceApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'WSTSC',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: SplashGate(prefs: prefs),
        );
      },
    );
  }
}

class SplashGate extends StatefulWidget {
  final SharedPreferences prefs;
  const SplashGate({super.key, required this.prefs});

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
    
    // Smooth transition
    await Future.delayed(const Duration(milliseconds: 1500)); 

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardWrapper()),
      );
    } else {
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.1), 
                  shape: BoxShape.circle
                ),
                child: Icon(
                  Icons.wind_power_rounded, // Using similar icon to logo
                  size: 80, 
                  color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'WSTSC',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3, 
                color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent
              ),
            ),
          ],
        ),
      ),
    );
  }
}
