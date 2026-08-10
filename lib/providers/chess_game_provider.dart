import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/engine/chess_board_state.dart';
import '../domain/engine/chess_piece.dart';
import '../domain/engine/chess_move.dart';
import '../domain/engine/chess_ai.dart';
import '../domain/models/game_session.dart';
import '../services/sound_manager.dart';
import '../services/haptic_manager.dart';

class ActiveGameState {
  final ChessBoardState boardState;
  final GameSession session;
  final BoardSquare? selectedSquare;
  final List<ChessMove> validMovesForSelected;
  final int whiteTimeSeconds;
  final int blackTimeSeconds;
  final bool isBoardFlipped;
  final bool isAiThinking;
  final AiDifficulty aiDifficulty;
  final ChessMove? lastMove;

  const ActiveGameState({
    required this.boardState,
    required this.session,
    this.selectedSquare,
    this.validMovesForSelected = const [],
    this.whiteTimeSeconds = 600,
    this.blackTimeSeconds = 600,
    this.isBoardFlipped = false,
    this.isAiThinking = false,
    this.aiDifficulty = AiDifficulty.medium,
    this.lastMove,
  });

  ActiveGameState copyWith({
    ChessBoardState? boardState,
    GameSession? session,
    BoardSquare? selectedSquare,
    bool clearSelected = false,
    List<ChessMove>? validMovesForSelected,
    int? whiteTimeSeconds,
    int? blackTimeSeconds,
    bool? isBoardFlipped,
    bool? isAiThinking,
    AiDifficulty? aiDifficulty,
    ChessMove? lastMove,
  }) {
    return ActiveGameState(
      boardState: boardState ?? this.boardState,
      session: session ?? this.session,
      selectedSquare: clearSelected ? null : (selectedSquare ?? this.selectedSquare),
      validMovesForSelected: validMovesForSelected ?? this.validMovesForSelected,
      whiteTimeSeconds: whiteTimeSeconds ?? this.whiteTimeSeconds,
      blackTimeSeconds: blackTimeSeconds ?? this.blackTimeSeconds,
      isBoardFlipped: isBoardFlipped ?? this.isBoardFlipped,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      lastMove: lastMove ?? this.lastMove,
    );
  }
}

final activeGameProvider = StateNotifierProvider.family<ActiveGameNotifier, ActiveGameState, GameSession>((ref, session) {
  return ActiveGameNotifier(session);
});

class ActiveGameNotifier extends StateNotifier<ActiveGameState> {
  Timer? _clockTimer;

  ActiveGameNotifier(GameSession session)
      : super(ActiveGameState(
          boardState: ChessBoardState.initial(),
          session: session,
          whiteTimeSeconds: session.timerMode.seconds == 0 ? 99999 : session.timerMode.seconds,
          blackTimeSeconds: session.timerMode.seconds == 0 ? 99999 : session.timerMode.seconds,
          isBoardFlipped: session.userColor == PieceColor.black,
        )) {
    _startTimer();
  }

  void _startTimer() {
    if (state.session.timerMode == TimerMode.unlimited) return;
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.boardState.status != GameStatus.active && state.boardState.status != GameStatus.check) {
        _clockTimer?.cancel();
        return;
      }

      if (state.boardState.activeColor == PieceColor.white) {
        final newTime = state.whiteTimeSeconds - 1;
        if (newTime <= 0) {
          _handleTimeout(PieceColor.white);
        } else {
          if (newTime == 10) SoundManager().playLowTime();
          state = state.copyWith(whiteTimeSeconds: newTime);
        }
      } else {
        final newTime = state.blackTimeSeconds - 1;
        if (newTime <= 0) {
          _handleTimeout(PieceColor.black);
        } else {
          if (newTime == 10) SoundManager().playLowTime();
          state = state.copyWith(blackTimeSeconds: newTime);
        }
      }
    });
  }

  void selectSquare(BoardSquare sq) {
    if (state.boardState.status != GameStatus.active && state.boardState.status != GameStatus.check) {
      return;
    }

    if (state.session.gameType == GameType.aiPractice &&
        state.boardState.activeColor != state.session.userColor) {
      return; // Waiting for AI
    }

    // If tapping selected square, clear selection
    if (state.selectedSquare == sq) {
      state = state.copyWith(clearSelected: true, validMovesForSelected: []);
      return;
    }

    // Check if tapping a destination move for current selection
    if (state.selectedSquare != null) {
      final matchingMove = state.validMovesForSelected.firstWhere(
        (m) => m.to == sq,
        orElse: () => ChessMove(from: sq, to: sq, piece: const ChessPiece(type: PieceType.pawn, color: PieceColor.white)),
      );

      if (matchingMove.from != matchingMove.to) {
        executeMove(matchingMove);
        return;
      }
    }

    // Otherwise select piece of active color
    final piece = state.boardState.getPiece(sq);
    if (piece != null && piece.color == state.boardState.activeColor) {
      final moves = state.boardState.getLegalMovesForSquare(sq);
      state = state.copyWith(
        selectedSquare: sq,
        validMovesForSelected: moves,
      );
      HapticManager().vibrateLight();
    } else {
      state = state.copyWith(clearSelected: true, validMovesForSelected: []);
    }
  }

  Future<void> executeMove(ChessMove move) async {
    final newBoard = state.boardState.makeMove(move);
    state = state.copyWith(
      boardState: newBoard,
      clearSelected: true,
      validMovesForSelected: [],
      lastMove: move,
    );

    // Audio & Haptic Feedback
    if (move.isCapture) {
      SoundManager().playCapture();
      HapticManager().vibrateMedium();
    } else {
      SoundManager().playMove();
    }

    if (newBoard.status == GameStatus.checkmate) {
      SoundManager().playVictory();
      HapticManager().vibrateHeavy();
    } else if (newBoard.status == GameStatus.check) {
      SoundManager().playCheck();
      HapticManager().vibrateMedium();
    }

    // AI Turn Trigger
    if (state.session.gameType == GameType.aiPractice &&
        newBoard.activeColor != state.session.userColor &&
        (newBoard.status == GameStatus.active || newBoard.status == GameStatus.check)) {
      _triggerAiTurn();
    }
  }

  Future<void> _triggerAiTurn() async {
    state = state.copyWith(isAiThinking: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final aiMove = await ChessAiEngine.getBestMove(state.boardState, state.aiDifficulty);
    state = state.copyWith(isAiThinking: false);

    if (aiMove != null) {
      executeMove(aiMove);
    }
  }

  void _handleTimeout(PieceColor color) {
    _clockTimer?.cancel();
    state = state.copyWith(
      boardState: state.boardState.copyWith(
        status: GameStatus.timeout,
        winner: color.opponent,
      ),
    );
    SoundManager().playVictory();
  }

  void resign(PieceColor playerResigning) {
    _clockTimer?.cancel();
    state = state.copyWith(
      boardState: state.boardState.copyWith(
        status: GameStatus.resignation,
        winner: playerResigning.opponent,
      ),
    );
    SoundManager().playVictory();
  }

  void flipBoard() {
    state = state.copyWith(isBoardFlipped: !state.isBoardFlipped);
  }

  void setAiDifficulty(AiDifficulty difficulty) {
    state = state.copyWith(aiDifficulty: difficulty);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
