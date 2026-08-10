import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../widgets/glass_card.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() async {
    final firestore = FirestoreService();
    final list = await firestore.getGlobalLeaderboard();
    if (mounted) {
      setState(() {
        _leaderboard = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Global Grandmaster Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : Column(
                children: [
                  const SizedBox(height: 16),

                  // Top 3 Podium (1st, 2nd, 3rd)
                  if (_leaderboard.length >= 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 2nd Place Silver
                          Expanded(child: _buildPodiumTile(_leaderboard[1], rank: 2, height: 130, color: const Color(0xFFC0C0C0))),
                          const SizedBox(width: 8),
                          // 1st Place Gold
                          Expanded(child: _buildPodiumTile(_leaderboard[0], rank: 1, height: 160, color: AppColors.primaryGold)),
                          const SizedBox(width: 8),
                          // 3rd Place Bronze
                          Expanded(child: _buildPodiumTile(_leaderboard[2], rank: 3, height: 110, color: const Color(0xFFCD7F32))),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Ranks 4+ List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _leaderboard.length > 3 ? _leaderboard.length - 3 : 0,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, index) {
                        final entry = _leaderboard[index + 3];
                        final isCurrentUser = currentUser?.username == entry.username;

                        return GlassCard(
                          borderColor: isCurrentUser ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '#${entry.rank}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCurrentUser ? AppColors.primaryGold : Colors.white70,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                                child: Text(
                                  entry.username.substring(0, 1),
                                  style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isCurrentUser ? AppColors.primaryGold : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${entry.country} • 🔥 ${entry.winStreak} win streak',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${entry.eloRating} ELO',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Sticky User Rank Footer Tile
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.darkSurface,
                      border: Border(top: BorderSide(color: AppColors.darkSurfaceBorder, width: 1)),
                    ),
                    child: Row(
                      children: [
                        const Text('#42', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.username ?? 'You',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                              const Text('Your Current Rank', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                            ],
                          ),
                        ),
                        Text(
                          '${currentUser?.currentRating ?? 1200} ELO',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPodiumTile(LeaderboardEntry entry, {required int rank, required double height, required Color color}) {
    return GlassCard(
      borderColor: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              '#$rank',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.eloRating} ELO',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms);
  }
}
