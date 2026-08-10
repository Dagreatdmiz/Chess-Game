import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Player Profile & Stats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Header Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.primaryGold.withOpacity(0.4),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryGold,
                      child: Text(
                        profile?.username.substring(0, 1) ?? 'P',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile?.username ?? 'Grandmaster Player',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile?.country ?? "Global"} • ${profile?.email ?? "guest@chessmaster.com"}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                    ),
                    const SizedBox(height: 16),

                    // Rating Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatChip('Current Rating', '${profile?.currentRating ?? 1200} ELO', AppColors.primaryGold),
                        const SizedBox(width: 12),
                        _buildStatChip('Highest Rating', '${profile?.highestRating ?? 1310} ELO', Colors.orangeAccent),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MATCH PERFORMANCE',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
                ),
              ),

              const SizedBox(height: 12),

              // Key Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Win Rate',
                      value: '${(profile?.winPercentage ?? 64.2).toStringAsFixed(1)}%',
                      icon: Icons.pie_chart,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Games Played',
                      value: '${profile?.gamesPlayed ?? 14}',
                      icon: Icons.sports_esports,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Victories',
                      value: '${profile?.gamesWon ?? 9}',
                      icon: Icons.emoji_events,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Defeats / Draws',
                      value: '${profile?.gamesLost ?? 3} / ${profile?.draws ?? 2}',
                      icon: Icons.handshake,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ACHIEVEMENTS & BADGES',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
                ),
              ),

              const SizedBox(height: 12),

              // Achievement Badges
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (profile?.achievements ?? ['First Victory', 'Academy Beginner', 'AI Slayer']).map((ach) {
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: AppColors.primaryGold, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          ach,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}
