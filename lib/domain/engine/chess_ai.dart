import 'dart:math';
import 'chess_piece.dart';
import 'chess_move.dart';
import 'chess_board_state.dart';

enum AiDifficulty {
  beginner, // Depth 1, 40% random move chance
  easy,     // Depth 2, 20% random move chance
  medium,   // Depth 2, strict evaluation
  hard,     // Depth 3, strict evaluation
  expert,   // Depth 4, positional tables
  master,   // Depth 5, positional tables & search optimization
}

class ChessAiEngine {
  static final Random _random = Random();

  // Positional evaluation tables (for White; inverted for Black)
  static const List<List<int>> _pawnTable = [
    [0,  0,  0,  0,  0,  0,  0,  0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [ 5,  5, 10, 25, 25, 10,  5,  5],
    [ 0,  0,  0, 20, 20,  0,  0,  0],
    [ 5, -5,-10,  0,  0,-10, -5,  5],
    [ 5, 10, 10,-20,-20, 10, 10,  5],
    [ 0,  0,  0,  0,  0,  0,  0,  0]
  ];

  static const List<List<int>> _knightTable = [
    [-50,-40,-30,-30,-30,-30,-40,-50],
    [-40,-20,  0,  0,  0,  0,-20,-40],
    [-30,  0, 10, 15, 15, 10,  0,-30],
    [-30,  5, 15, 20, 20, 15,  5,-30],
    [-30,  0, 15, 20, 20, 15,  0,-30],
    [-30,  5, 10, 15, 15, 10,  5,-30],
    [-40,-20,  0,  5,  5,  0,-20,-40],
    [-50,-40,-30,-30,-30,-30,-40,-50]
  ];

  static const List<List<int>> _bishopTable = [
    [-20,-10,-10,-10,-10,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5, 10, 10,  5,  0,-10],
    [-10,  5,  5, 10, 10,  5,  5,-10],
    [-10,  0, 10, 10, 10, 10,  0,-10],
    [-10, 10, 10, 10, 10, 10, 10,-10],
    [-10,  5,  0,  0,  0,  0,  5,-10],
    [-20,-10,-10,-10,-10,-10,-10,-20]
  ];

  static Future<ChessMove?> getBestMove(ChessBoardState board, AiDifficulty difficulty) async {
    final moves = board.getAllLegalMoves(board.activeColor);
    if (moves.isEmpty) return null;

    // Handle Beginner & Easy randomness
    if (difficulty == AiDifficulty.beginner && _random.nextDouble() < 0.4) {
      return moves[_random.nextInt(moves.length)];
    }
    if (difficulty == AiDifficulty.easy && _random.nextDouble() < 0.2) {
      return moves[_random.nextInt(moves.length)];
    }

    final depth = _getDepthForDifficulty(difficulty);
    ChessMove? bestMove;
    int bestScore = board.activeColor == PieceColor.white ? -999999 : 999999;
    int alpha = -999999;
    int beta = 999999;

    // Sort moves to optimize alpha-beta pruning (captures first)
    moves.sort((a, b) => (b.isCapture ? 1 : 0).compareTo(a.isCapture ? 1 : 0));

    for (final move in moves) {
      final nextBoard = board.makeMove(move);
      final score = _minimax(nextBoard, depth - 1, alpha, beta, nextBoard.activeColor == PieceColor.white);

      if (board.activeColor == PieceColor.white) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
        alpha = max(alpha, bestScore);
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
        beta = min(beta, bestScore);
      }

      if (beta <= alpha) break;
    }

    return bestMove ?? moves[_random.nextInt(moves.length)];
  }

  static int _getDepthForDifficulty(AiDifficulty difficulty) {
    switch (difficulty) {
      case AiDifficulty.beginner:
        return 1;
      case AiDifficulty.easy:
        return 2;
      case AiDifficulty.medium:
        return 2;
      case AiDifficulty.hard:
        return 3;
      case AiDifficulty.expert:
        return 4;
      case AiDifficulty.master:
        return 5;
    }
  }

  static int _minimax(ChessBoardState board, int depth, int alpha, int beta, bool isMaximizing) {
    if (depth == 0 || board.status != GameStatus.active && board.status != GameStatus.check) {
      return _evaluateBoard(board);
    }

    final moves = board.getAllLegalMoves(board.activeColor);
    if (moves.isEmpty) {
      return _evaluateBoard(board);
    }

    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in moves) {
        final nextBoard = board.makeMove(move);
        final eval = _minimax(nextBoard, depth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in moves) {
        final nextBoard = board.makeMove(move);
        final eval = _minimax(nextBoard, depth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static int _evaluateBoard(ChessBoardState board) {
    if (board.status == GameStatus.checkmate) {
      return board.winner == PieceColor.white ? 99990 : -99990;
    }
    if (board.status == GameStatus.stalemate ||
        board.status == GameStatus.draw50MoveRule ||
        board.status == GameStatus.drawInsufficientMaterial) {
      return 0;
    }

    int score = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece != null) {
          int pieceScore = piece.value * 100;

          // Positional bonuses
          if (piece.type == PieceType.pawn) {
            pieceScore += piece.color == PieceColor.white
                ? _pawnTable[r][c]
                : _pawnTable[7 - r][c];
          } else if (piece.type == PieceType.knight) {
            pieceScore += piece.color == PieceColor.white
                ? _knightTable[r][c]
                : _knightTable[7 - r][c];
          } else if (piece.type == PieceType.bishop) {
            pieceScore += piece.color == PieceColor.white
                ? _bishopTable[r][c]
                : _bishopTable[7 - r][c];
          }

          if (piece.color == PieceColor.white) {
            score += pieceScore;
          } else {
            score -= pieceScore;
          }
        }
      }
    }

    return score;
  }
}
