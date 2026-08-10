import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/match_history.dart';
import '../core/theme/board_styles.dart';

class StorageService {
  static const String _keyHistory = 'match_history';
  static const String _keyBoardTheme = 'board_theme_mode';
  static const String _keyPieceStyle = 'piece_style_mode';
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keySoundEnabled = 'is_sound_enabled';
  static const String _keyHapticEnabled = 'is_haptic_enabled';

  Future<void> saveMatchHistory(MatchHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getMatchHistory();
    history.insert(0, item);
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  Future<List<MatchHistoryItem>> getMatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyHistory);
    if (jsonStr == null || jsonStr.isEmpty) {
      return _getMockMatchHistory();
    }
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => MatchHistoryItem.fromJson(e)).toList();
    } catch (_) {
      return _getMockMatchHistory();
    }
  }

  Future<void> saveThemeSettings({
    required BoardThemeMode boardTheme,
    required PieceStyleMode pieceStyle,
    required bool isDarkMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBoardTheme, boardTheme.name);
    await prefs.setString(_keyPieceStyle, pieceStyle.name);
    await prefs.setBool(_keyDarkMode, isDarkMode);
  }

  Future<Map<String, dynamic>> getThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'boardTheme': prefs.getString(_keyBoardTheme) ?? BoardThemeMode.wood.name,
      'pieceStyle': prefs.getString(_keyPieceStyle) ?? PieceStyleMode.classic.name,
      'isDarkMode': prefs.getBool(_keyDarkMode) ?? true,
    };
  }

  Future<void> saveAudioSettings({
    required bool soundEnabled,
    required bool hapticEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, soundEnabled);
    await prefs.setBool(_keyHapticEnabled, hapticEnabled);
  }

  Future<Map<String, bool>> getAudioSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'soundEnabled': prefs.getBool(_keySoundEnabled) ?? true,
      'hapticEnabled': prefs.getBool(_keyHapticEnabled) ?? true,
    };
  }

  List<MatchHistoryItem> _getMockMatchHistory() {
    return [
      MatchHistoryItem(
        id: 'match_101',
        opponentName: 'Stockfish AI (Medium)',
        opponentAvatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=AiMedium',
        opponentElo: 1500,
        result: MatchResult.win,
        durationText: '8m 42s',
        playedAt: DateTime.now().subtract(const Duration(hours: 2)),
        totalMoves: 34,
        openingName: 'Sicilian Defense',
        pgn: '1. e4 c5 2. Nf3 d6 3. d4 cxd4 4. Nxd4 Nf6 5. Nc3 a6 6. Be3 e5 7. Nb3 Be6',
        moveList: const [],
      ),
      MatchHistoryItem(
        id: 'match_102',
        opponentName: 'Grandmaster_X',
        opponentAvatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=GM_X',
        opponentElo: 1850,
        result: MatchResult.loss,
        durationText: '14m 10s',
        playedAt: DateTime.now().subtract(const Duration(days: 1)),
        totalMoves: 48,
        openingName: 'Ruy Lopez',
        pgn: '1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6',
        moveList: const [],
      ),
      MatchHistoryItem(
        id: 'match_103',
        opponentName: 'LAN_Opponent_42',
        opponentAvatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=LanOpponent',
        opponentElo: 1320,
        result: MatchResult.draw,
        durationText: '11m 05s',
        playedAt: DateTime.now().subtract(const Duration(days: 3)),
        totalMoves: 56,
        openingName: 'Queen\'s Gambit Declined',
        pgn: '1. d4 d5 2. c4 e6 3. Nc3 Nf6 4. Bg5 Be7 5. e3 O-O 6. Nf3 h6 7. Bh4 b6',
        moveList: const [],
      ),
    ];
  }
}
