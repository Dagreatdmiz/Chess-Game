import '../engine/chess_move.dart';

enum MatchResult { win, loss, draw }

class MatchHistoryItem {
  final String id;
  final String opponentName;
  final String opponentAvatar;
  final int opponentElo;
  final MatchResult result;
  final String durationText;
  final DateTime playedAt;
  final int totalMoves;
  final String openingName;
  final String pgn;
  final List<ChessMove> moveList;

  const MatchHistoryItem({
    required this.id,
    required this.opponentName,
    required this.opponentAvatar,
    required this.opponentElo,
    required this.result,
    required this.durationText,
    required this.playedAt,
    required this.totalMoves,
    required this.openingName,
    required this.pgn,
    required this.moveList,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponentName': opponentName,
      'opponentAvatar': opponentAvatar,
      'opponentElo': opponentElo,
      'result': result.name,
      'durationText': durationText,
      'playedAt': playedAt.toIso8601String(),
      'totalMoves': totalMoves,
      'openingName': openingName,
      'pgn': pgn,
      'moveList': moveList.map((m) => m.toJson()).toList(),
    };
  }

  factory MatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return MatchHistoryItem(
      id: json['id'] as String,
      opponentName: json['opponentName'] as String,
      opponentAvatar: json['opponentAvatar'] as String? ?? '',
      opponentElo: json['opponentElo'] as int? ?? 1200,
      result: MatchResult.values.firstWhere((e) => e.name == json['result']),
      durationText: json['durationText'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      totalMoves: json['totalMoves'] as int,
      openingName: json['openingName'] as String? ?? 'Standard',
      pgn: json['pgn'] as String? ?? '',
      moveList: (json['moveList'] as List? ?? [])
          .map((m) => ChessMove.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
