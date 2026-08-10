import 'chess_piece.dart';
import 'chess_move.dart';

enum GameStatus {
  active,
  check,
  checkmate,
  stalemate,
  drawRepetition,
  drawInsufficientMaterial,
  draw50MoveRule,
  drawAgreement,
  resignation,
  timeout,
}

class ChessBoardState {
  final List<List<ChessPiece?>> grid;
  final PieceColor activeColor;
  final bool whiteCanCastleKingside;
  final bool whiteCanCastleQueenside;
  final bool blackCanCastleKingside;
  final bool blackCanCastleQueenside;
  final BoardSquare? enPassantTarget;
  final int halfMoveClock; // 50-move rule counter
  final int fullMoveNumber;
  final List<ChessMove> moveHistory;
  final List<ChessPiece> capturedPieces;
  final List<String> fenHistory;
  final GameStatus status;
  final PieceColor? winner;

  ChessBoardState({
    required this.grid,
    this.activeColor = PieceColor.white,
    this.whiteCanCastleKingside = true,
    this.whiteCanCastleQueenside = true,
    this.blackCanCastleKingside = true,
    this.blackCanCastleQueenside = true,
    this.enPassantTarget,
    this.halfMoveClock = 0,
    this.fullMoveNumber = 1,
    this.moveHistory = const [],
    this.capturedPieces = const [],
    this.fenHistory = const [],
    this.status = GameStatus.active,
    this.winner,
  });

  factory ChessBoardState.initial() {
    final grid = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));

    // Black pieces (row 0 & 1)
    grid[0][0] = const ChessPiece(type: PieceType.rook, color: PieceColor.black);
    grid[0][1] = const ChessPiece(type: PieceType.knight, color: PieceColor.black);
    grid[0][2] = const ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    grid[0][3] = const ChessPiece(type: PieceType.queen, color: PieceColor.black);
    grid[0][4] = const ChessPiece(type: PieceType.king, color: PieceColor.black);
    grid[0][5] = const ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    grid[0][6] = const ChessPiece(type: PieceType.knight, color: PieceColor.black);
    grid[0][7] = const ChessPiece(type: PieceType.rook, color: PieceColor.black);
    for (int col = 0; col < 8; col++) {
      grid[1][col] = const ChessPiece(type: PieceType.pawn, color: PieceColor.black);
    }

    // White pieces (row 6 & 7)
    for (int col = 0; col < 8; col++) {
      grid[6][col] = const ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }
    grid[7][0] = const ChessPiece(type: PieceType.rook, color: PieceColor.white);
    grid[7][1] = const ChessPiece(type: PieceType.knight, color: PieceColor.white);
    grid[7][2] = const ChessPiece(type: PieceType.bishop, color: PieceColor.white);
    grid[7][3] = const ChessPiece(type: PieceType.queen, color: PieceColor.white);
    grid[7][4] = const ChessPiece(type: PieceType.king, color: PieceColor.white);
    grid[7][5] = const ChessPiece(type: PieceType.bishop, color: PieceColor.white);
    grid[7][6] = const ChessPiece(type: PieceType.knight, color: PieceColor.white);
    grid[7][7] = const ChessPiece(type: PieceType.rook, color: PieceColor.white);

    final state = ChessBoardState(grid: grid);
    return state.copyWith(fenHistory: [state.toFen()]);
  }

  ChessPiece? getPiece(BoardSquare sq) {
    if (!sq.isValid) return null;
    return grid[sq.row][sq.col];
  }

  ChessBoardState copyWith({
    List<List<ChessPiece?>>? grid,
    PieceColor? activeColor,
    bool? whiteCanCastleKingside,
    bool? whiteCanCastleQueenside,
    bool? blackCanCastleKingside,
    bool? blackCanCastleQueenside,
    BoardSquare? enPassantTarget,
    bool clearEnPassant = false,
    int? halfMoveClock,
    int? fullMoveNumber,
    List<ChessMove>? moveHistory,
    List<ChessPiece>? capturedPieces,
    List<String>? fenHistory,
    GameStatus? status,
    PieceColor? winner,
    bool clearWinner = false,
  }) {
    return ChessBoardState(
      grid: grid ?? this.grid.map((row) => List<ChessPiece?>.from(row)).toList(),
      activeColor: activeColor ?? this.activeColor,
      whiteCanCastleKingside: whiteCanCastleKingside ?? this.whiteCanCastleKingside,
      whiteCanCastleQueenside: whiteCanCastleQueenside ?? this.whiteCanCastleQueenside,
      blackCanCastleKingside: blackCanCastleKingside ?? this.blackCanCastleKingside,
      blackCanCastleQueenside: blackCanCastleQueenside ?? this.blackCanCastleQueenside,
      enPassantTarget: clearEnPassant ? null : (enPassantTarget ?? this.enPassantTarget),
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      fullMoveNumber: fullMoveNumber ?? this.fullMoveNumber,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
      capturedPieces: capturedPieces ?? List.from(this.capturedPieces),
      fenHistory: fenHistory ?? List.from(this.fenHistory),
      status: status ?? this.status,
      winner: clearWinner ? null : (winner ?? this.winner),
    );
  }

  BoardSquare? findKing(PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = grid[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          return BoardSquare(r, c);
        }
      }
    }
    return null;
  }

  bool isSquareAttacked(BoardSquare sq, PieceColor attackerColor) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = grid[r][c];
        if (piece != null && piece.color == attackerColor) {
          final moves = _getRawPseudoMoves(BoardSquare(r, c), piece, includeCastling: false);
          if (moves.any((m) => m.to == sq)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isInCheck(PieceColor color) {
    final kingSquare = findKing(color);
    if (kingSquare == null) return false;
    return isSquareAttacked(kingSquare, color.opponent);
  }

  List<ChessMove> getLegalMovesForSquare(BoardSquare from) {
    final piece = getPiece(from);
    if (piece == null || piece.color != activeColor) return [];

    final pseudoMoves = _getRawPseudoMoves(from, piece, includeCastling: true);
    final legalMoves = <ChessMove>[];

    for (final move in pseudoMoves) {
      final simulatedBoard = _applyMoveInternal(move);
      if (!simulatedBoard.isInCheck(activeColor)) {
        // Additional check for castling: king cannot pass through check
        if (move.isCastling) {
          final direction = move.to.col > move.from.col ? 1 : -1;
          final passThroughSquare = BoardSquare(move.from.row, move.from.col + direction);
          if (isSquareAttacked(move.from, activeColor.opponent) ||
              isSquareAttacked(passThroughSquare, activeColor.opponent)) {
            continue;
          }
        }
        legalMoves.add(move);
      }
    }

    return legalMoves;
  }

  List<ChessMove> getAllLegalMoves(PieceColor color) {
    final allMoves = <ChessMove>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = grid[r][c];
        if (piece != null && piece.color == color) {
          final sq = BoardSquare(r, c);
          allMoves.addAll(getLegalMovesForSquare(sq));
        }
      }
    }
    return allMoves;
  }

  List<ChessMove> _getRawPseudoMoves(BoardSquare from, ChessPiece piece, {bool includeCastling = true}) {
    final moves = <ChessMove>[];
    final color = piece.color;
    final forwardDir = color == PieceColor.white ? -1 : 1;
    final startRank = color == PieceColor.white ? 6 : 1;

    switch (piece.type) {
      case PieceType.pawn:
        // Single forward
        final oneStep = BoardSquare(from.row + forwardDir, from.col);
        if (oneStep.isValid && getPiece(oneStep) == null) {
          if ((color == PieceColor.white && oneStep.row == 0) ||
              (color == PieceColor.black && oneStep.row == 7)) {
            for (final promo in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
              moves.add(ChessMove(from: from, to: oneStep, piece: piece, promotionType: promo));
            }
          } else {
            moves.add(ChessMove(from: from, to: oneStep, piece: piece));
          }

          // Double forward
          final twoSteps = BoardSquare(from.row + (forwardDir * 2), from.col);
          if (from.row == startRank && getPiece(twoSteps) == null) {
            moves.add(ChessMove(from: from, to: twoSteps, piece: piece));
          }
        }

        // Standard captures
        for (final colOffset in [-1, 1]) {
          final capSq = BoardSquare(from.row + forwardDir, from.col + colOffset);
          if (capSq.isValid) {
            final targetPiece = getPiece(capSq);
            if (targetPiece != null && targetPiece.color != color) {
              if ((color == PieceColor.white && capSq.row == 0) ||
                  (color == PieceColor.black && capSq.row == 7)) {
                for (final promo in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
                  moves.add(ChessMove(from: from, to: capSq, piece: piece, capturedPiece: targetPiece, promotionType: promo));
                }
              } else {
                moves.add(ChessMove(from: from, to: capSq, piece: piece, capturedPiece: targetPiece));
              }
            } else if (capSq == enPassantTarget) {
              // En Passant capture
              final epCapturedSq = BoardSquare(from.row, from.col + colOffset);
              final epCapturedPiece = getPiece(epCapturedSq);
              moves.add(ChessMove(
                from: from,
                to: capSq,
                piece: piece,
                capturedPiece: epCapturedPiece,
                isEnPassant: true,
              ));
            }
          }
        }
        break;

      case PieceType.knight:
        const knightOffsets = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1]
        ];
        for (final offset in knightOffsets) {
          final target = BoardSquare(from.row + offset[0], from.col + offset[1]);
          if (target.isValid) {
            final targetPiece = getPiece(target);
            if (targetPiece == null || targetPiece.color != color) {
              moves.add(ChessMove(from: from, to: target, piece: piece, capturedPiece: targetPiece));
            }
          }
        }
        break;

      case PieceType.bishop:
        _addRayMoves(from, piece, moves, [[-1, -1], [-1, 1], [1, -1], [1, 1]]);
        break;

      case PieceType.rook:
        _addRayMoves(from, piece, moves, [[-1, 0], [1, 0], [0, -1], [0, 1]]);
        break;

      case PieceType.queen:
        _addRayMoves(from, piece, moves, [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ]);
        break;

      case PieceType.king:
        const kingOffsets = [
          [-1, -1], [-1, 0], [-1, 1],
          [0, -1],           [0, 1],
          [1, -1],  [1, 0],  [1, 1]
        ];
        for (final offset in kingOffsets) {
          final target = BoardSquare(from.row + offset[0], from.col + offset[1]);
          if (target.isValid) {
            final targetPiece = getPiece(target);
            if (targetPiece == null || targetPiece.color != color) {
              moves.add(ChessMove(from: from, to: target, piece: piece, capturedPiece: targetPiece));
            }
          }
        }

        // Castling
        if (includeCastling && !piece.hasMoved) {
          final row = color == PieceColor.white ? 7 : 0;
          final canCastleKingside = color == PieceColor.white ? whiteCanCastleKingside : blackCanCastleKingside;
          final canCastleQueenside = color == PieceColor.white ? whiteCanCastleQueenside : blackCanCastleQueenside;

          // Kingside
          if (canCastleKingside &&
              getPiece(BoardSquare(row, 5)) == null &&
              getPiece(BoardSquare(row, 6)) == null) {
            final rook = getPiece(BoardSquare(row, 7));
            if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
              moves.add(ChessMove(from: from, to: BoardSquare(row, 6), piece: piece, isCastling: true));
            }
          }

          // Queenside
          if (canCastleQueenside &&
              getPiece(BoardSquare(row, 1)) == null &&
              getPiece(BoardSquare(row, 2)) == null &&
              getPiece(BoardSquare(row, 3)) == null) {
            final rook = getPiece(BoardSquare(row, 0));
            if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
              moves.add(ChessMove(from: from, to: BoardSquare(row, 2), piece: piece, isCastling: true));
            }
          }
        }
        break;
    }

    return moves;
  }

  void _addRayMoves(BoardSquare from, ChessPiece piece, List<ChessMove> moves, List<List<int>> directions) {
    for (final dir in directions) {
      int r = from.row + dir[0];
      int c = from.col + dir[1];
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final targetSq = BoardSquare(r, c);
        final targetPiece = getPiece(targetSq);
        if (targetPiece == null) {
          moves.add(ChessMove(from: from, to: targetSq, piece: piece));
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(ChessMove(from: from, to: targetSq, piece: piece, capturedPiece: targetPiece));
          }
          break; // Blocked by piece
        }
        r += dir[0];
        c += dir[1];
      }
    }
  }

  ChessBoardState makeMove(ChessMove move) {
    final nextState = _applyMoveInternal(move);
    final nextColor = activeColor.opponent;

    // Check SAN notation creation
    final formattedMove = _formatSanMove(move, nextState);
    final finalMove = move.copyWith(
      sanNotation: formattedMove,
      isCheck: nextState.isInCheck(nextColor),
    );

    final updatedCaptured = List<ChessPiece>.from(capturedPieces);
    if (move.capturedPiece != null) {
      updatedCaptured.add(move.capturedPiece!);
    }

    // Check game termination conditions
    final nextLegalMoves = nextState.getAllLegalMoves(nextColor);
    final inCheck = nextState.isInCheck(nextColor);

    GameStatus nextStatus = GameStatus.active;
    PieceColor? gameWinner;

    if (nextLegalMoves.isEmpty) {
      if (inCheck) {
        nextStatus = GameStatus.checkmate;
        gameWinner = activeColor;
      } else {
        nextStatus = GameStatus.stalemate;
      }
    } else if (inCheck) {
      nextStatus = GameStatus.check;
    } else if (nextState.halfMoveClock >= 100) {
      nextStatus = GameStatus.draw50MoveRule;
    } else if (nextState._isInsufficientMaterial()) {
      nextStatus = GameStatus.drawInsufficientMaterial;
    } else if (nextState._isThreefoldRepetition()) {
      nextStatus = GameStatus.drawRepetition;
    }

    final newFenHistory = List<String>.from(fenHistory)..add(nextState.toFen());

    return nextState.copyWith(
      moveHistory: [...moveHistory, finalMove],
      capturedPieces: updatedCaptured,
      fenHistory: newFenHistory,
      status: nextStatus,
      winner: gameWinner,
    );
  }

  ChessBoardState _applyMoveInternal(ChessMove move) {
    final newGrid = grid.map((row) => List<ChessPiece?>.from(row)).toList();
    BoardSquare? newEpTarget;

    // Move main piece
    ChessPiece movedPiece = move.piece.copyWith(hasMoved: true);
    if (move.promotionType != null) {
      movedPiece = ChessPiece(type: move.promotionType!, color: move.piece.color, hasMoved: true);
    }

    newGrid[move.from.row][move.from.col] = null;
    newGrid[move.to.row][move.to.col] = movedPiece;

    // En Passant capture removal
    if (move.isEnPassant) {
      final epCapRow = move.from.row;
      final epCapCol = move.to.col;
      newGrid[epCapRow][epCapCol] = null;
    }

    // Double pawn push sets EP target
    if (move.piece.type == PieceType.pawn && (move.to.row - move.from.row).abs() == 2) {
      final epRow = (move.from.row + move.to.row) ~/ 2;
      newEpTarget = BoardSquare(epRow, move.from.col);
    }

    // Castling rook move
    if (move.isCastling) {
      final row = move.from.row;
      if (move.to.col == 6) {
        // Kingside
        final rook = newGrid[row][7];
        if (rook != null) {
          newGrid[row][7] = null;
          newGrid[row][5] = rook.copyWith(hasMoved: true);
        }
      } else if (move.to.col == 2) {
        // Queenside
        final rook = newGrid[row][0];
        if (rook != null) {
          newGrid[row][0] = null;
          newGrid[row][3] = rook.copyWith(hasMoved: true);
        }
      }
    }

    // Update castling rights
    bool wCK = whiteCanCastleKingside;
    bool wCQ = whiteCanCastleQueenside;
    bool bCK = blackCanCastleKingside;
    bool bCQ = blackCanCastleQueenside;

    if (move.piece.type == PieceType.king) {
      if (move.piece.color == PieceColor.white) {
        wCK = false;
        wCQ = false;
      } else {
        bCK = false;
        bCQ = false;
      }
    }

    if (move.from == const BoardSquare(7, 7) || move.to == const BoardSquare(7, 7)) wCK = false;
    if (move.from == const BoardSquare(7, 0) || move.to == const BoardSquare(7, 0)) wCQ = false;
    if (move.from == const BoardSquare(0, 7) || move.to == const BoardSquare(0, 7)) bCK = false;
    if (move.from == const BoardSquare(0, 0) || move.to == const BoardSquare(0, 0)) bCQ = false;

    // Reset or increment half move clock
    final newHalfMove = (move.piece.type == PieceType.pawn || move.isCapture) ? 0 : halfMoveClock + 1;
    final newFullMove = activeColor == PieceColor.black ? fullMoveNumber + 1 : fullMoveNumber;

    return ChessBoardState(
      grid: newGrid,
      activeColor: activeColor.opponent,
      whiteCanCastleKingside: wCK,
      whiteCanCastleQueenside: wCQ,
      blackCanCastleKingside: bCK,
      blackCanCastleQueenside: bCQ,
      enPassantTarget: newEpTarget,
      halfMoveClock: newHalfMove,
      fullMoveNumber: newFullMove,
      moveHistory: List.from(moveHistory),
      capturedPieces: List.from(capturedPieces),
      fenHistory: List.from(fenHistory),
    );
  }

  String _formatSanMove(ChessMove move, ChessBoardState nextState) {
    if (move.isCastling) {
      return move.to.col == 6 ? 'O-O' : 'O-O-O';
    }

    final pSymbol = move.piece.type == PieceType.pawn ? '' : move.piece.symbol.toUpperCase();
    final captureStr = move.isCapture ? (move.piece.type == PieceType.pawn ? '${move.from.notation[0]}x' : 'x') : '';
    final destStr = move.to.notation;
    final promoStr = move.promotionType != null ? '=${move.promotionType!.name[0].toUpperCase()}' : '';
    
    final inCheck = nextState.isInCheck(activeColor.opponent);
    final inCheckmate = nextState.getAllLegalMoves(activeColor.opponent).isEmpty && inCheck;
    final checkStr = inCheckmate ? '#' : (inCheck ? '+' : '');

    return '$pSymbol$captureStr$destStr$promoStr$checkStr';
  }

  bool _isInsufficientMaterial() {
    final pieces = <ChessPiece>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (grid[r][c] != null) pieces.add(grid[r][c]!);
      }
    }

    if (pieces.length <= 2) return true; // K vs K
    if (pieces.length == 3) {
      // K+B vs K or K+N vs K
      final nonKings = pieces.where((p) => p.type != PieceType.king);
      if (nonKings.every((p) => p.type == PieceType.bishop || p.type == PieceType.knight)) {
        return true;
      }
    }
    return false;
  }

  bool _isThreefoldRepetition() {
    final currentFen = toFen().split(' ').sublist(0, 4).join(' ');
    int count = 0;
    for (final fen in fenHistory) {
      final baseFen = fen.split(' ').sublist(0, 4).join(' ');
      if (baseFen == currentFen) {
        count++;
        if (count >= 3) return true;
      }
    }
    return false;
  }

  String toFen() {
    final sb = StringBuffer();

    for (int r = 0; r < 8; r++) {
      int emptyCount = 0;
      for (int c = 0; c < 8; c++) {
        final p = grid[r][c];
        if (p == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            sb.write(emptyCount);
            emptyCount = 0;
          }
          sb.write(p.symbol);
        }
      }
      if (emptyCount > 0) sb.write(emptyCount);
      if (r < 7) sb.write('/');
    }

    sb.write(' ');
    sb.write(activeColor == PieceColor.white ? 'w' : 'b');
    sb.write(' ');

    String castling = '';
    if (whiteCanCastleKingside) castling += 'K';
    if (whiteCanCastleQueenside) castling += 'Q';
    if (blackCanCastleKingside) castling += 'k';
    if (blackCanCastleQueenside) castling += 'q';
    sb.write(castling.isEmpty ? '-' : castling);

    sb.write(' ');
    sb.write(enPassantTarget != null ? enPassantTarget!.notation : '-');
    sb.write(' ');
    sb.write(halfMoveClock);
    sb.write(' ');
    sb.write(fullMoveNumber);

    return sb.toString();
  }

  String exportPgn() {
    final sb = StringBuffer();
    sb.writeln('[Event "Chess Master Online Match"]');
    sb.writeln('[Site "Mobile"]');
    sb.writeln('[Date "${DateTime.now().toIso8601String().substring(0, 10)}"]');
    sb.writeln('[White "${winner == PieceColor.white ? "Winner" : "White"}"]');
    sb.writeln('[Black "${winner == PieceColor.black ? "Winner" : "Black"}"]');
    sb.writeln('[Result "${_getResultString()}"]');
    sb.writeln();

    for (int i = 0; i < moveHistory.length; i++) {
      if (i % 2 == 0) {
        sb.write('${(i ~/ 2) + 1}. ');
      }
      sb.write('${moveHistory[i].sanNotation} ');
    }
    sb.write(_getResultString());
    return sb.toString();
  }

  String _getResultString() {
    if (status == GameStatus.checkmate || status == GameStatus.resignation || status == GameStatus.timeout) {
      return winner == PieceColor.white ? '1-0' : '0-1';
    }
    if (status == GameStatus.stalemate ||
        status == GameStatus.draw50MoveRule ||
        status == GameStatus.drawAgreement ||
        status == GameStatus.drawInsufficientMaterial ||
        status == GameStatus.drawRepetition) {
      return '1/2-1/2';
    }
    return '*';
  }
}
