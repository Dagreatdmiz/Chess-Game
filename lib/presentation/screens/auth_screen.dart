import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App Branding
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryGold,
                child: Text('♔', style: TextStyle(fontSize: 40, color: Colors.black)),
              ).animate().scale(duration: 500.ms),
              const SizedBox(height: 12),
              const Text(
                'CHESS MASTER ONLINE',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sign in to sync ratings & battle grandmasters',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
              ),

              const SizedBox(height: 32),

              // Login Form Card
              Expanded(
                child: SingleChildScrollView(
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
                            prefixIcon: const Icon(Icons.email, color: AppColors.primaryGold),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
                            prefixIcon: const Icon(Icons.lock, color: AppColors.primaryGold),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  await ref.read(authProvider.notifier).signInWithEmail(
                                        _emailController.text.isNotEmpty ? _emailController.text : 'player@chessmaster.com',
                                        _passwordController.text,
                                      );
                                  setState(() => _isLoading = false);
                                  _navigateToHome();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Text('Sign In / Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),

                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Social Buttons
                        OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authProvider.notifier).signInWithGoogle();
                            _navigateToHome();
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.redAccent),
                          label: const Text('Continue with Google', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authProvider.notifier).signInWithApple();
                            _navigateToHome();
                          },
                          icon: const Icon(Icons.apple, size: 24, color: Colors.white),
                          label: const Text('Continue with Apple', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Guest Login
              TextButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signInAsGuest();
                  _navigateToHome();
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
