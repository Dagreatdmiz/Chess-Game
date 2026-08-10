import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/board_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/glass_card.dart';
import 'auth_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings & Customization', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BOARD THEME',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              // Board Themes Horizontal List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: BoardThemeMode.values.map((mode) {
                    final isSelected = themeState.boardThemeMode == mode;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GlassCard(
                        onTap: () => themeNotifier.setBoardTheme(mode),
                        borderColor: isSelected ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
                                    BoardStyleConfig(themeMode: mode).lightSquareColor,
                                    BoardStyleConfig(themeMode: mode).darkSquareColor,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              BoardStyleConfig(themeMode: mode).themeName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primaryGold : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'PIECE ART STYLE',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              Row(
                children: PieceStyleMode.values.map((style) {
                  final isSelected = themeState.pieceStyleMode == style;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GlassCard(
                        onTap: () => themeNotifier.setPieceStyle(style),
                        borderColor: isSelected ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            style.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primaryGold : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              const Text(
                'AUDIO & HAPTICS',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Sound Effects (FX)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Move, capture, and check audio clips', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      value: themeState.soundEnabled,
                      activeColor: AppColors.primaryGold,
                      onChanged: (_) => themeNotifier.toggleSound(),
                    ),
                    const Divider(color: Colors.white12),
                    SwitchListTile(
                      title: const Text('Haptic Vibration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Vibrate device on captures and victories', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      value: themeState.hapticEnabled,
                      activeColor: AppColors.primaryGold,
                      onChanged: (_) => themeNotifier.toggleHaptic(),
                    ),
                    const Divider(color: Colors.white12),
                    SwitchListTile(
                      title: const Text('Dark Mode Interface', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Sleek dark theme aesthetics', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      value: themeState.isDarkMode,
                      activeColor: AppColors.primaryGold,
                      onChanged: (_) => themeNotifier.toggleDarkMode(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Sign Out of Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
