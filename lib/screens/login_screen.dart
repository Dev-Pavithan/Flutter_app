import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import '../mock_data.dart';
import 'dashboard_wrapper.dart';

class LoginScreen extends StatefulWidget {
  final bool showInstallPrompt;

  const LoginScreen({super.key, this.showInstallPrompt = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _passcode = "";
  bool _isLoading = false;
  final String _correctPasscode = "1234";

  void _handleKeyPress(String key) {
    if (_passcode.length < 4) {
      setState(() {
        _passcode += key;
      });
      if (_passcode.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void _handleDelete() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      });
    }
  }

  void _verifyPasscode() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (_passcode == _correctPasscode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _passcode = "";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Incorrect Passcode. Try 1234'), backgroundColor: AppTheme.darkError, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _handleBiometric() {
    // Simulate biometric check
    _passcode = _correctPasscode;
    _verifyPasscode();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppTheme.darkAccent.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.school, size: 48, color: AppTheme.darkAccent),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Scan to Login', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Enter your 4-digit security PIN', style: GoogleFonts.inter(color: Colors.white54)),
                const SizedBox(height: 48),
                
                // Passcode Dots
                _isLoading 
                  ? const CircularProgressIndicator(color: AppTheme.darkAccent)
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildDot(index < _passcode.length)),
                  ),
                
                const Spacer(),

                // Keypad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    children: [
                      _buildKeypadRow(['1', '2', '3']),
                      _buildKeypadRow(['4', '5', '6']),
                      _buildKeypadRow(['7', '8', '9']),
                      _buildKeypadRow(['0', 'bio', 'del']),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isFilled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isFilled ? AppTheme.darkAccent : Colors.white24,
        shape: BoxShape.circle,
        border: isFilled ? null : Border.all(color: Colors.white12),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    Widget child;
    if (key == 'bio') {
      child = const Icon(LucideIcons.fingerprint, color: AppTheme.darkAccent, size: 32);
    } else if (key == 'del') {
      child = const Icon(LucideIcons.delete, color: Colors.white54, size: 24);
    } else {
      child = Text(key, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
    }

    return InkWell(
      onTap: () {
        if (key == 'bio') {
          _handleBiometric();
        } else if (key == 'del') {
          _handleDelete();
        } else {
          _handleKeyPress(key);
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }

  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0C141C), Color(0xFF151F28), Color(0xFF0C141C)],
      ),
    ),
  );
}
