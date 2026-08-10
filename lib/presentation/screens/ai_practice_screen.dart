import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/chess_ai.dart';
import '../../domain/engine/chess_piece.dart';
import '../../domain/models/game_session.dart';
import '../../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import 'game_screen.dart';

class AiPracticeScreen extends ConsumerStatefulWidget {
  const AiPracticeScreen({super.key});

  @override
  ConsumerState<AiPracticeScreen> createState() => _AiPracticeScreenState();
}

class _AiPracticeScreenState extends ConsumerState<AiPracticeScreen> {
  AiDifficulty _selectedDifficulty = AiDifficulty.medium;
  PieceColor _selectedColor = PieceColor.white;
  TimerMode _selectedTimer = TimerMode.unlimited;

  void _startAiGame() {
    final user = ref.read(authProvider);

    PieceColor finalColor = _selectedColor;
    if (_selectedColor == PieceColor.white && Random().nextBool()) {
      // Random pick when user selects White vs Black option
    }

    final isUserWhite = finalColor == PieceColor.white;

    final session = GameSession(
      id: 'ai_session_${DateTime.now().millisecondsSinceEpoch}',
      gameType: GameType.aiPractice,
      timerMode: _selectedTimer,
      playerWhiteName: isUserWhite ? (user?.username ?? 'Grandmaster Player') : 'Stockfish AI (${_difficultyName(_selectedDifficulty)})',
      playerBlackName: isUserWhite ? 'Stockfish AI (${_difficultyName(_selectedDifficulty)})' : (user?.username ?? 'Grandmaster Player'),
      playerWhiteElo: isUserWhite ? (user?.currentRating ?? 1200) : _difficultyElo(_selectedDifficulty),
      playerBlackElo: isUserWhite ? _difficultyElo(_selectedDifficulty) : (user?.currentRating ?? 1200),
      userColor: finalColor,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Practice vs Stockfish AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECT AI DIFFICULTY',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              // Difficulty Cards
              Row(
                children: AiDifficulty.values.map((diff) {
                  final isSelected = _selectedDifficulty == diff;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GlassCard(
                        onTap: () => setState(() => _selectedDifficulty = diff),
                        borderColor: isSelected ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        child: Column(
                          children: [
                            Icon(
                              _difficultyIcon(diff),
                              color: isSelected ? AppColors.primaryGold : Colors.white70,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _difficultyName(diff),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected ? AppColors.primaryGold : Colors.white,
                              ),
                            ),
                            Text(
                              '${_difficultyElo(diff)} ELO',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              const Text(
                'CHOOSE YOUR COLOR',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              // Side Selection
              Row(
                children: [
                  Expanded(
                    child: _buildSideCard(
                      title: 'White',
                      subtitle: 'First Move',
                      icon: '♔',
                      color: Colors.white,
                      isSelected: _selectedColor == PieceColor.white,
                      onTap: () => setState(() => _selectedColor = PieceColor.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSideCard(
                      title: 'Black',
                      subtitle: 'Counter Attack',
                      icon: '♚',
                      color: Colors.grey,
                      isSelected: _selectedColor == PieceColor.black,
                      onTap: () => setState(() => _selectedColor = PieceColor.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'TIME CONTROL',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              Row(
                children: [TimerMode.unlimited, TimerMode.fiveMin, TimerMode.tenMin, TimerMode.fifteenMin].map((mode) {
                  final isSelected = _selectedTimer == mode;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GlassCard(
                        onTap: () => setState(() => _selectedTimer = mode),
                        borderColor: isSelected ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            mode.label,
                            style: TextStyle(
                              fontSize: 12,
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

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startAiGame,
                  icon: const Icon(Icons.smart_toy, color: Colors.black),
                  label: const Text('START AI MATCH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  String _difficultyName(AiDifficulty diff) {
    switch (diff) {
      case AiDifficulty.beginner:
        return 'Beginner';
      case AiDifficulty.easy:
        return 'Easy';
      case AiDifficulty.medium:
        return 'Medium';
      case AiDifficulty.hard:
        return 'Hard';
      case AiDifficulty.expert:
        return 'Expert';
      case AiDifficulty.master:
        return 'Master';
    }
  }

  int _difficultyElo(AiDifficulty diff) {
    switch (diff) {
      case AiDifficulty.beginner:
        return 600;
      case AiDifficulty.easy:
        return 800;
      case AiDifficulty.medium:
        return 1400;
      case AiDifficulty.hard:
        return 2000;
      case AiDifficulty.expert:
        return 2400;
      case AiDifficulty.master:
        return 2800;
    }
  }

  IconData _difficultyIcon(AiDifficulty diff) {
    switch (diff) {
      case AiDifficulty.beginner:
        return Icons.child_care;
      case AiDifficulty.easy:
        return Icons.sentiment_satisfied;
      case AiDifficulty.medium:
        return Icons.psychology;
      case AiDifficulty.hard:
        return Icons.whatshot;
      case AiDifficulty.expert:
        return Icons.auto_awesome;
      case AiDifficulty.master:
        return Icons.military_tech;
    }
  }
}
