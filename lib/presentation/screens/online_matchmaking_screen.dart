import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/chess_piece.dart';
import '../../domain/models/game_session.dart';
import '../../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import 'game_screen.dart';

class OnlineMatchmakingScreen extends ConsumerStatefulWidget {
  const OnlineMatchmakingScreen({super.key});

  @override
  ConsumerState<OnlineMatchmakingScreen> createState() => _OnlineMatchmakingScreenState();
}

class _OnlineMatchmakingScreenState extends ConsumerState<OnlineMatchmakingScreen> {
  TimerMode _selectedTimer = TimerMode.fiveMin;
  bool _isSearching = false;
  int _searchSeconds = 0;
  Timer? _searchTimer;

  void _startMatchmaking() {
    setState(() {
      _isSearching = true;
      _searchSeconds = 0;
    });

    _searchTimer?.cancel();
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _searchSeconds++);

      // Simulate matching with real opponent after 3 seconds
      if (_searchSeconds >= 3) {
        _searchTimer?.cancel();
        _launchMatchedGame();
      }
    });
  }

  void _cancelMatchmaking() {
    _searchTimer?.cancel();
    setState(() => _isSearching = false);
  }

  void _launchMatchedGame() {
    final user = ref.read(authProvider);

    final session = GameSession(
      id: 'online_session_${DateTime.now().millisecondsSinceEpoch}',
      gameType: GameType.online,
      timerMode: _selectedTimer,
      playerWhiteName: user?.username ?? 'Grandmaster Player',
      playerBlackName: 'Grandmaster_Opponent_88',
      playerWhiteAvatar: user?.avatarUrl,
      playerBlackAvatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=Opponent88',
      playerWhiteElo: user?.currentRating ?? 1200,
      playerBlackElo: (user?.currentRating ?? 1200) + 25,
      userColor: PieceColor.white,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(session: session)),
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Online Ranked Matchmaking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // User ELO Badge Header
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryGold,
                      child: Text(
                        profile?.username.substring(0, 1) ?? 'P',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.username ?? 'Player',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          'Current Rating: ${profile?.currentRating ?? 1200} ELO',
                          style: const TextStyle(fontSize: 12, color: AppColors.primaryGold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!_isSearching) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SELECT TIME CONTROL',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 12),

                // Timer Options Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: TimerMode.values.where((t) => t != TimerMode.unlimited).map((mode) {
                      final isSelected = _selectedTimer == mode;
                      return GlassCard(
                        onTap: () => setState(() => _selectedTimer = mode),
                        borderColor: isSelected ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getTimerIcon(mode),
                              size: 28,
                              color: isSelected ? AppColors.primaryGold : Colors.white70,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mode.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected ? AppColors.primaryGold : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Start Matchmaking Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _startMatchmaking,
                    icon: const Icon(Icons.flash_on, color: Colors.black),
                    label: const Text('FIND MATCH NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                  ),
                ),
              ] else ...[
                // Searching Radar Ripple Animation
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGold.withOpacity(0.1),
                          border: Border.all(color: AppColors.primaryGold, width: 2),
                        ),
                        child: const Center(
                          child: SpinKitRipple(
                            color: AppColors.primaryGold,
                            size: 110,
                          ),
                        ),
                      ).animate().scale(duration: 800.ms, curve: Curves.easeInOut),

                      const SizedBox(height: 32),

                      const Text(
                        'Searching for Opponent...',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Time Elapsed: ${_searchSeconds}s • Mode: ${_selectedTimer.label}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
                      ),

                      const SizedBox(height: 48),

                      OutlinedButton(
                        onPressed: _cancelMatchmaking,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel Search', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTimerIcon(TimerMode mode) {
    switch (mode) {
      case TimerMode.oneMin:
      case TimerMode.threeMin:
        return Icons.bolt;
      case TimerMode.fiveMin:
      case TimerMode.tenMin:
        return Icons.timer;
      case TimerMode.fifteenMin:
      case TimerMode.thirtyMin:
        return Icons.hourglass_full;
      case TimerMode.unlimited:
        return Icons.all_inclusive;
    }
  }
}
