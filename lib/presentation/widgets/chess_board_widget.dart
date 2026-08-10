import 'package:flutter/material.dart';
import '../../domain/engine/chess_board_state.dart';
import '../../domain/engine/chess_piece.dart';
import '../../domain/engine/chess_move.dart';
import '../../core/theme/board_styles.dart';
import '../../core/constants/app_colors.dart';

class ChessBoardWidget extends StatelessWidget {
  final ChessBoardState boardState;
  final BoardSquare? selectedSquare;
  final List<ChessMove> validMoves;
  final Function(BoardSquare) onSquareTap;
  final bool isFlipped;
  final BoardStyleConfig styleConfig;
  final ChessMove? lastMove;

  const ChessBoardWidget({
    super.key,
    required this.boardState,
    required this.selectedSquare,
    required this.validMoves,
    required this.onSquareTap,
    this.isFlipped = false,
    this.styleConfig = const BoardStyleConfig(),
    this.lastMove,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: List.generate(8, (rIndex) {
              final row = isFlipped ? 7 - rIndex : rIndex;
              return Expanded(
                child: Row(
                  children: List.generate(8, (cIndex) {
                    final col = isFlipped ? 7 - cIndex : cIndex;
                    final sq = BoardSquare(row, col);
                    final piece = boardState.getPiece(sq);
                    final isLightSquare = (row + col) % 2 == 0;
                    final squareColor = isLightSquare
                        ? styleConfig.lightSquareColor
                        : styleConfig.darkSquareColor;

                    final isSelected = selectedSquare == sq;
                    final isValidDestination = validMoves.any((m) => m.to == sq);
                    final isLastMoveSquare = lastMove != null && (lastMove!.from == sq || lastMove!.to == sq);
                    final isKingInCheck = piece != null &&
                        piece.type == PieceType.king &&
                        piece.color == boardState.activeColor &&
                        boardState.isInCheck(boardState.activeColor);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onSquareTap(sq),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _calculateSquareColor(
                              baseColor: squareColor,
                              isSelected: isSelected,
                              isLastMove: isLastMoveSquare,
                              isCheck: isKingInCheck,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Coordinate labels
                              if (col == (isFlipped ? 7 : 0))
                                Positioned(
                                  top: 2,
                                  left: 3,
                                  child: Text(
                                    '${8 - row}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isLightSquare ? styleConfig.darkSquareColor : styleConfig.lightSquareColor,
                                    ),
                                  ),
                                ),
                              if (row == (isFlipped ? 0 : 7))
                                Positioned(
                                  bottom: 2,
                                  right: 3,
                                  child: Text(
                                    String.fromCharCode('a'.codeUnitAt(0) + col),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isLightSquare ? styleConfig.darkSquareColor : styleConfig.lightSquareColor,
                                    ),
                                  ),
                                ),

                              // Chess Piece Symbol / Graphic
                              if (piece != null)
                                Center(
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: _buildPieceWidget(piece),
                                  ),
                                ),

                              // Legal Move Indicator (Dot or Ring)
                              if (isValidDestination)
                                Center(
                                  child: Container(
                                    width: piece != null ? 36 : 14,
                                    height: piece != null ? 36 : 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: piece != null
                                          ? AppColors.legalDot.withOpacity(0.4)
                                          : AppColors.legalDot,
                                      border: piece != null
                                          ? Border.all(color: AppColors.legalDot, width: 3)
                                          : null,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Color _calculateSquareColor({
    required Color baseColor,
    required bool isSelected,
    required bool isLastMove,
    required bool isCheck,
  }) {
    if (isCheck) return AppColors.checkHighlight;
    if (isSelected) return AppColors.moveHighlight;
    if (isLastMove) return AppColors.lastMoveHighlight;
    return baseColor;
  }

  Widget _buildPieceWidget(ChessPiece piece) {
    final isWhite = piece.color == PieceColor.white;
    String unicodeSymbol;
    switch (piece.type) {
      case PieceType.king:
        unicodeSymbol = isWhite ? '♔' : '♚';
        break;
      case PieceType.queen:
        unicodeSymbol = isWhite ? '♕' : '♛';
        break;
      case PieceType.rook:
        unicodeSymbol = isWhite ? '♖' : '♜';
        break;
      case PieceType.bishop:
        unicodeSymbol = isWhite ? '♗' : '♝';
        break;
      case PieceType.knight:
        unicodeSymbol = isWhite ? '♘' : '♞';
        break;
      case PieceType.pawn:
        unicodeSymbol = isWhite ? '♙' : '♟';
        break;
    }

    return Text(
      unicodeSymbol,
      style: TextStyle(
        fontSize: 36,
        color: isWhite ? Colors.white : const Color(0xFF1E293B),
        shadows: [
          Shadow(
            color: isWhite ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
    );
  }
}
