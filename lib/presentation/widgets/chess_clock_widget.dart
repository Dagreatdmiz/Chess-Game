import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_colors.dart';

class ChessClockWidget extends StatelessWidget {
  final String playerName;
  final int playerElo;
  final int timeSeconds;
  final bool isActive;
  final bool isTopPlayer;

  const ChessClockWidget({
    super.key,
    required this.playerName,
    required this.playerElo,
    required this.timeSeconds,
    required this.isActive,
    this.isTopPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLowTime = timeSeconds <= 30 && timeSeconds > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? (isLowTime ? Colors.red.withOpacity(0.3) : AppColors.primaryGold.withOpacity(0.2))
            : AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? (isLowTime ? Colors.red : AppColors.primaryGold)
              : AppColors.darkSurfaceBorder,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isActive ? AppColors.primaryGold : Colors.grey,
                child: Text(
                  playerName.isNotEmpty ? playerName[0].toUpperCase() : 'P',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    AppFormatters.formatElo(playerElo),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppFormatters.formatTime(timeSeconds),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Monospace',
                color: isLowTime
                    ? Colors.redAccent
                    : (isActive ? AppColors.primaryGold : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
