import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import 'online_matchmaking_screen.dart';
import 'wifi_multiplayer_screen.dart';
import 'private_room_screen.dart';
import 'ai_practice_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeDashboardTab(),
      const LearnScreen(),
      const AiPracticeScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.darkSurfaceBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primaryGold,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Play AI'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboardTab extends ConsumerWidget {
  const _HomeDashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Top Profile Bar
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryGold,
                        child: Text(
                          profile?.username.substring(0, 1) ?? 'P',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.username ?? 'Grandmaster Player',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Rating: ${profile?.currentRating ?? 1200} ELO • ${profile?.country ?? "Global"}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings, color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hero Banner Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.primaryGold.withOpacity(0.4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SEASON 4 LEAGUE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Master Every Move',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Battle real opponents online or play via local WiFi LAN.',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('♔', style: TextStyle(fontSize: 54, color: AppColors.primaryGold)),
                      ],
                    ),
                  ).animate().scale(duration: 400.ms),

                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'MULTIPLAYER MODES',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Play Online Card
                  _MenuCard(
                    title: 'Play Online',
                    subtitle: 'Automatic global matchmaking',
                    icon: Icons.public,
                    gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnlineMatchmakingScreen()),
                      );
                    },
                  ).animate().slideX(begin: -0.2, duration: 300.ms),

                  const SizedBox(height: 12),

                  // Play via WiFi Card
                  _MenuCard(
                    title: 'Play via WiFi / LAN',
                    subtitle: 'Auto-discover nearby players on local network',
                    icon: Icons.wifi,
                    gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WifiMultiplayerScreen()),
                      );
                    },
                  ).animate().slideX(begin: 0.2, duration: 350.ms),

                  const SizedBox(height: 12),

                  // Room Code Card
                  _MenuCard(
                    title: 'Private Room Code',
                    subtitle: 'Create 6-digit code or scan QR to play with friend',
                    icon: Icons.qr_code,
                    gradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivateRoomScreen()),
                      );
                    },
                  ).animate().slideX(begin: -0.2, duration: 400.ms),

                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ACADEMY & PRACTICE',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _GridMenuCard(
                          title: 'Learn Chess',
                          subtitle: 'Interactive Academy',
                          icon: Icons.school,
                          color: Colors.amber,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LearnScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GridMenuCard(
                          title: 'Practice vs AI',
                          subtitle: 'Beginner to Master',
                          icon: Icons.smart_toy,
                          color: Colors.cyan,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AiPracticeScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _GridMenuCard(
                          title: 'Leaderboard',
                          subtitle: 'Global & Friends',
                          icon: Icons.leaderboard,
                          color: Colors.orangeAccent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GridMenuCard(
                          title: 'Game History',
                          subtitle: 'PGN Move Replay',
                          icon: Icons.movie,
                          color: Colors.pinkAccent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 32, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GridMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }
}
