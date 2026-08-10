import 'dart:async';
import 'dart:math';
import '../domain/models/game_session.dart';
import '../domain/models/leaderboard_entry.dart';
import '../domain/engine/chess_piece.dart';

class FirestoreService {
  static final Random _random = Random();

  static String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  Future<GameSession> createPrivateRoom({
    required String hostName,
    required TimerMode timerMode,
  }) async {
    final code = generateRoomCode();
    return GameSession(
      id: 'room_$code',
      gameType: GameType.privateRoom,
      timerMode: timerMode,
      playerWhiteName: hostName,
      playerBlackName: 'Waiting for friend...',
      userColor: PieceColor.white,
      roomCode: code,
      isMyTurn: true,
    );
  }

  Future<GameSession?> joinPrivateRoom({
    required String roomCode,
    required String guestName,
  }) async {
    if (roomCode.length != 6) return null;
    return GameSession(
      id: 'room_${roomCode.toUpperCase()}',
      gameType: GameType.privateRoom,
      timerMode: TimerMode.fiveMin,
      playerWhiteName: 'HostPlayer',
      playerBlackName: guestName,
      userColor: PieceColor.black,
      roomCode: roomCode.toUpperCase(),
      isMyTurn: false,
    );
  }

  Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    return getLeaderboard();
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String category = 'Global',
    String timeframe = 'All-Time',
  }) async {
    return [
      const LeaderboardEntry(rank: 1, userId: 'u1', username: 'MagnusCarlsen_AI', avatarUrl: '', country: 'Norway', eloRating: 2882, gamesWon: 1450, winStreak: 22),
      const LeaderboardEntry(rank: 2, userId: 'u2', username: 'HikaruNakamura', avatarUrl: '', country: 'United States', eloRating: 2875, gamesWon: 1390, winStreak: 18),
      const LeaderboardEntry(rank: 3, userId: 'u3', username: 'FabianoCaruana', avatarUrl: '', country: 'United States', eloRating: 2804, gamesWon: 1120, winStreak: 9),
      const LeaderboardEntry(rank: 4, userId: 'u4', username: 'AlirezaFirouzja', avatarUrl: '', country: 'France', eloRating: 2795, gamesWon: 980, winStreak: 7),
      const LeaderboardEntry(rank: 5, userId: 'u5', username: 'DingLiren', avatarUrl: '', country: 'China', eloRating: 2780, gamesWon: 890, winStreak: 5),
      const LeaderboardEntry(rank: 6, userId: 'u6', username: 'ChessWizard_99', avatarUrl: '', country: 'United Kingdom', eloRating: 2450, gamesWon: 450, winStreak: 12),
      const LeaderboardEntry(rank: 7, userId: 'u7', username: 'TacticalMaster', avatarUrl: '', country: 'Germany', eloRating: 2390, gamesWon: 390, winStreak: 4),
      const LeaderboardEntry(rank: 8, userId: 'u8', username: 'GrandmasterGuest', avatarUrl: '', country: 'United States', eloRating: 1250, gamesWon: 9, winStreak: 2),
    ];
  }
}

