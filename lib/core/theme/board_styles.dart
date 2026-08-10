import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BoardThemeMode { wood, glass, neon, marble, emerald }

enum PieceStyleMode { classic, modern, minimalist, vintage }

class BoardStyleConfig {
  final BoardThemeMode themeMode;
  final PieceStyleMode pieceStyle;

  const BoardStyleConfig({
    this.themeMode = BoardThemeMode.wood,
    this.pieceStyle = PieceStyleMode.classic,
  });

  Color get lightSquareColor {
    switch (themeMode) {
      case BoardThemeMode.wood:
        return AppColors.woodLightSquare;
      case BoardThemeMode.glass:
        return AppColors.glassLightSquare;
      case BoardThemeMode.neon:
        return AppColors.neonLightSquare;
      case BoardThemeMode.marble:
        return const Color(0xFFE2E8F0);
      case BoardThemeMode.emerald:
        return const Color(0xFFD1FAE5);
    }
  }

  Color get darkSquareColor {
    switch (themeMode) {
      case BoardThemeMode.wood:
        return AppColors.woodDarkSquare;
      case BoardThemeMode.glass:
        return AppColors.glassDarkSquare;
      case BoardThemeMode.neon:
        return const Color(0xFF0F172A);
      case BoardThemeMode.marble:
        return const Color(0xFF64748B);
      case BoardThemeMode.emerald:
        return const Color(0xFF065F46);
    }
  }

  String get themeName {
    switch (themeMode) {
      case BoardThemeMode.wood:
        return 'Classic Wood';
      case BoardThemeMode.glass:
        return 'Dark Glass';
      case BoardThemeMode.neon:
        return 'Cyber Neon';
      case BoardThemeMode.marble:
        return 'Imperial Marble';
      case BoardThemeMode.emerald:
        return 'Royal Emerald';
    }
  }
}
