import '../engine/chess_piece.dart';

enum GameType { online, privateRoom, wifiLan, aiPractice, localPassAndPlay }

enum TimerMode {
  oneMin(60, "1 Minute"),
  threeMin(180, "3 Minutes"),
  fiveMin(300, "5 Minutes"),
  tenMin(600, "10 Minutes"),
  fifteenMin(900, "15 Minutes"),
  thirtyMin(1800, "30 Minutes"),
  unlimited(0, "Unlimited");

  final int seconds;
  final String label;
  const TimerMode(this.seconds, this.label);
}

class GameSession {
  final String id;
  final GameType gameType;
  final TimerMode timerMode;
  final String playerWhiteName;
  final String playerBlackName;
  final String? playerWhiteAvatar;
  final String? playerBlackAvatar;
  final int playerWhiteElo;
  final int playerBlackElo;
  final PieceColor userColor;
  final String? roomCode;
  final String? hostIp;
  final bool isMyTurn;

  const GameSession({
    required this.id,
    required this.gameType,
    required this.timerMode,
    required this.playerWhiteName,
    required this.playerBlackName,
    this.playerWhiteAvatar,
    this.playerBlackAvatar,
    this.playerWhiteElo = 1200,
    this.playerBlackElo = 1200,
    this.userColor = PieceColor.white,
    this.roomCode,
    this.hostIp,
    this.isMyTurn = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType.name,
      'timerMode': timerMode.name,
      'playerWhiteName': playerWhiteName,
      'playerBlackName': playerBlackName,
      'playerWhiteAvatar': playerWhiteAvatar,
      'playerBlackAvatar': playerBlackAvatar,
      'playerWhiteElo': playerWhiteElo,
      'playerBlackElo': playerBlackElo,
      'userColor': userColor.name,
      'roomCode': roomCode,
      'hostIp': hostIp,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      gameType: GameType.values.firstWhere((e) => e.name == json['gameType']),
      timerMode: TimerMode.values.firstWhere((e) => e.name == json['timerMode']),
      playerWhiteName: json['playerWhiteName'] as String,
      playerBlackName: json['playerBlackName'] as String,
      playerWhiteAvatar: json['playerWhiteAvatar'] as String?,
      playerBlackAvatar: json['playerBlackAvatar'] as String?,
      playerWhiteElo: json['playerWhiteElo'] as int? ?? 1200,
      playerBlackElo: json['playerBlackElo'] as int? ?? 1200,
      userColor: PieceColor.values.firstWhere((e) => e.name == json['userColor']),
      roomCode: json['roomCode'] as String?,
      hostIp: json['hostIp'] as String?,
    );
  }
}
