import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/board_styles.dart';
import '../services/storage_service.dart';

class ThemeState {
  final BoardThemeMode boardThemeMode;
  final PieceStyleMode pieceStyleMode;
  final bool isDarkMode;
  final bool soundEnabled;
  final bool hapticEnabled;

  const ThemeState({
    this.boardThemeMode = BoardThemeMode.wood,
    this.pieceStyleMode = PieceStyleMode.classic,
    this.isDarkMode = true,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  BoardStyleConfig get config => BoardStyleConfig(
        themeMode: boardThemeMode,
        pieceStyle: pieceStyleMode,
      );

  ThemeState copyWith({
    BoardThemeMode? boardThemeMode,
    PieceStyleMode? pieceStyleMode,
    bool? isDarkMode,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return ThemeState(
      boardThemeMode: boardThemeMode ?? this.boardThemeMode,
      pieceStyleMode: pieceStyleMode ?? this.pieceStyleMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  final StorageService _storage;

  ThemeNotifier(this._storage) : super(const ThemeState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.getThemeSettings();
    state = state.copyWith(
      boardThemeMode: BoardThemeMode.values.firstWhere((e) => e.name == settings['boardTheme']),
      pieceStyleMode: PieceStyleMode.values.firstWhere((e) => e.name == settings['pieceStyle']),
      isDarkMode: settings['isDarkMode'] as bool,
    );
  }

  void setBoardTheme(BoardThemeMode mode) {
    state = state.copyWith(boardThemeMode: mode);
    _save();
  }

  void setPieceStyle(PieceStyleMode style) {
    state = state.copyWith(pieceStyleMode: style);
    _save();
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _save();
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  void _save() {
    _storage.saveThemeSettings(
      boardTheme: state.boardThemeMode,
      pieceStyle: state.pieceStyleMode,
      isDarkMode: state.isDarkMode,
    );
  }
}
