import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import '../mock_data.dart';
import 'dashboard_wrapper.dart';
import '../pwa_interop.dart';

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
  bool _hideInstallBanner = false;

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

  Future<void> _handleBiometric() async {
    // Show our custom themed biometric scanning dialog immediately
    if (mounted) {
      _showScanningDialog();
    }
  }

  void _showScanningDialog() {
    final LocalAuthentication auth = LocalAuthentication();
    bool isAuthenticating = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Trigger authentication once the dialog is ready
            if (!isAuthenticating) {
              isAuthenticating = true;
              Future.delayed(const Duration(milliseconds: 500), () async {
                bool canCheck = false;
                try {
                  canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();
                } catch (_) {}
                
                if (canCheck) {
                  try {
                    // Using real authentication logic as requested by user
                    final bool didAuth = await auth.authenticate(
                      localizedReason: 'Please authenticate to login',
                    );

                    if (didAuth && mounted) {
                      Navigator.pop(context);
                      setState(() => _passcode = _correctPasscode);
                      _verifyPasscode();
                    } else if (mounted) {
                      // If authentication fails, close dialog and show feedback
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication failed.'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      // If plugin error occurs (like MissingPluginException on web), show install modal
                      if (e.toString().contains('MissingPluginException')) {
                         setState(() => _hideInstallBanner = false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Authentication error: $e'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    }
                  }
                } else if (mounted) {
                  // If device doesn't support biometrics or is in browser
                  Navigator.pop(context);
                  setState(() => _hideInstallBanner = false);
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppTheme.darkAccent.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: AppTheme.darkAccent.withOpacity(0.05), blurRadius: 40, spreadRadius: 0),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Biometric Security',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Place your finger on the sensor',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                    ),
                    const SizedBox(height: 48),
                    
                    // Continuous Looping Fingerprint Pulse
                    const _ScanningCircle(),
                    
                    const SizedBox(height: 48),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white24)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _triggerInstall() async {
    final result = await installPWA();
    if (result == true) {
      setState(() => _hideInstallBanner = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showBanner = widget.showInstallPrompt && !_hideInstallBanner;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.school, size: 48, color: AppTheme.darkAccent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Verify & Continue', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
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
                
                const Spacer(flex: 3),

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

          // New Modal Themed Install UI
          if (showBanner)
            Positioned.fill(
              child: Container(
                color: Colors.black87.withOpacity(0.8),
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: AppTheme.darkAccent.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: AppTheme.darkAccent.withOpacity(0.1), blurRadius: 40, spreadRadius: 0),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.downloadCloud, color: AppTheme.darkAccent, size: 38),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Enhance Your Experience',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Install WSTSC on your home screen for quick access and biometric face login support.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _triggerInstall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkAccent,
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Install Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _hideInstallBanner = true),
                          child: Text('Maybe Later', style: GoogleFonts.inter(color: Colors.white38)),
                        ),
                      ],
                    ),
                  ),
                ),
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

class _ScanningCircle extends StatefulWidget {
  const _ScanningCircle();
  @override
  State<_ScanningCircle> createState() => _ScanningCircleState();
}

class _ScanningCircleState extends State<_ScanningCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value = 0.8 + (_controller.value * 0.4);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.darkAccent.withOpacity(0.3 * (2 - value))),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkAccent.withOpacity(0.1 * (2 - value)),
                blurRadius: 20 * value,
                spreadRadius: 5 * value,
              )
            ],
          ),
          child: Transform.scale(
            scale: value,
            child: const Icon(LucideIcons.fingerprint, color: AppTheme.darkAccent, size: 64),
          ),
        );
      },
    );
  }
}
