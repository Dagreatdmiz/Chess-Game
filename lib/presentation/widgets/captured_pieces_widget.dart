import 'package:flutter/material.dart';
import '../../domain/engine/chess_piece.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<ChessPiece> capturedPieces;
  final PieceColor targetColor;

  const CapturedPiecesWidget({
    super.key,
    required this.capturedPieces,
    required this.targetColor,
  });

  @override
  Widget build(BuildContext context) {
    final pieces = capturedPieces.where((p) => p.color == targetColor).toList();

    int totalAdvantage = 0;
    final opponentPieces = capturedPieces.where((p) => p.color == targetColor.opponent).toList();
    final myValue = pieces.fold(0, (sum, p) => sum + p.value);
    final oppValue = opponentPieces.fold(0, (sum, p) => sum + p.value);
    totalAdvantage = myValue - oppValue;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: pieces.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    _getSymbol(p),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (totalAdvantage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+$totalAdvantage',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
          ),
      ],
    );
  }

  String _getSymbol(ChessPiece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return '♟';
      case PieceType.knight:
        return '♞';
      case PieceType.bishop:
        return '♝';
      case PieceType.rook:
        return '♜';
      case PieceType.queen:
        return '♛';
      case PieceType.king:
        return '♚';
    }
  }
}
