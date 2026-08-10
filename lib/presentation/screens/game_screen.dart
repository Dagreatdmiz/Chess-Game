import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/chess_board_state.dart';
import '../../domain/engine/chess_piece.dart';
import '../../domain/models/game_session.dart';
import '../../providers/chess_game_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/sound_manager.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/chess_clock_widget.dart';
import '../widgets/captured_pieces_widget.dart';
import '../widgets/move_history_list.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/glass_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameSession session;

  const GameScreen({super.key, required this.session});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showMoveHistory = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(activeGameProvider(widget.session));
    final gameNotifier = ref.read(activeGameProvider(widget.session).notifier);
    final themeState = ref.watch(themeProvider);

    final isGameOver = gameState.boardState.status != GameStatus.active &&
        gameState.boardState.status != GameStatus.check;

    final isUserWhite = widget.session.userColor == PieceColor.white;
    final topPlayerName = isUserWhite ? widget.session.playerBlackName : widget.session.playerWhiteName;
    final topPlayerElo = isUserWhite ? widget.session.playerBlackElo : widget.session.playerWhiteElo;
    final topPlayerColor = isUserWhite ? PieceColor.black : PieceColor.white;
    final topTime = isUserWhite ? gameState.blackTimeSeconds : gameState.whiteTimeSeconds;

    final bottomPlayerName = isUserWhite ? widget.session.playerWhiteName : widget.session.playerBlackName;
    final bottomPlayerElo = isUserWhite ? widget.session.playerWhiteElo : widget.session.playerBlackElo;
    final bottomPlayerColor = isUserWhite ? PieceColor.white : PieceColor.black;
    final bottomTime = isUserWhite ? gameState.whiteTimeSeconds : gameState.blackTimeSeconds;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => _confirmExit(context),
            ),
            title: Text(
              _getGameModeTitle(widget.session.gameType),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.flip_camera_android, color: AppColors.primaryGold),
                tooltip: 'Flip Board',
                onPressed: () => gameNotifier.flipBoard(),
              ),
              IconButton(
                icon: Icon(
                  themeState.soundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white70,
                ),
                tooltip: 'Toggle Sound',
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleSound();
                  SoundManager().toggleMute();
                },
              ),
              IconButton(
                icon: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                tooltip: 'Resign Match',
                onPressed: () => _confirmResign(context, gameNotifier, widget.session.userColor),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Opponent Player Header Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildPlayerBar(
                    name: topPlayerName,
                    elo: topPlayerElo,
                    color: topPlayerColor,
                    timeSeconds: topTime,
                    isActiveTurn: gameState.boardState.activeColor == topPlayerColor,
                    boardState: gameState.boardState,
                    isAiThinking: gameState.isAiThinking && topPlayerColor == PieceColor.black,
                  ),
                ),

                const Spacer(),

                // Active Interactive Chess Board
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ChessBoardWidget(
                    boardState: gameState.boardState,
                    selectedSquare: gameState.selectedSquare,
                    validMoves: gameState.validMovesForSelected,
                    isFlipped: gameState.isBoardFlipped,
                    styleConfig: themeState.config,
                    lastMove: gameState.lastMove,
                    onSquareTap: (sq) => gameNotifier.selectSquare(sq),
                  ),
                ),

                const Spacer(),

                // Bottom User Player Header Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildPlayerBar(
                    name: bottomPlayerName,
                    elo: bottomPlayerElo,
                    color: bottomPlayerColor,
                    timeSeconds: bottomTime,
                    isActiveTurn: gameState.boardState.activeColor == bottomPlayerColor,
                    boardState: gameState.boardState,
                    isAiThinking: false,
                  ),
                ),

                // Bottom Action Tools Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.darkSurface,
                    border: Border(top: BorderSide(color: AppColors.darkSurfaceBorder, width: 1)),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showMoveHistory = !_showMoveHistory);
                        },
                        icon: const Icon(Icons.history, size: 18),
                        label: Text(_showMoveHistory ? 'Hide Moves' : 'Move History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (gameState.boardState.status == GameStatus.check)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: const Text(
                            'CHECK!',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                          ).animate().shake(duration: 400.ms),
                        ),
                    ],
                  ),
                ),

                // Expandable Move History Drawer
                if (_showMoveHistory)
                  Container(
                    height: 120,
                    color: AppColors.darkBackground,
                    padding: const EdgeInsets.all(8),
                    child: MoveHistoryList(moveHistory: gameState.boardState.moveHistory),
                  ),
              ],
            ),
          ),
        ),

        // Victory Confetti Overlay
        if (isGameOver && gameState.boardState.winner == widget.session.userColor)
          const ConfettiOverlay(show: true, child: SizedBox.shrink()),

        // Game Over Summary Dialog Overlay
        if (isGameOver)
          _buildGameOverModal(context, gameState.boardState, widget.session),
      ],
    );
  }

  Widget _buildPlayerBar({
    required String name,
    required int elo,
    required PieceColor color,
    required int timeSeconds,
    required bool isActiveTurn,
    required ChessBoardState boardState,
    required bool isAiThinking,
  }) {
    final captured = boardState.capturedPieces.where((p) => p.color == color.opponent).toList();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: isActiveTurn ? AppColors.primaryGold : AppColors.darkSurfaceBorder,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color == PieceColor.white ? Colors.white : Colors.black,
            child: Text(
              color == PieceColor.white ? '♔' : '♚',
              style: TextStyle(
                fontSize: 20,
                color: color == PieceColor.white ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($elo)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                    ),
                    if (isAiThinking) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                CapturedPiecesWidget(capturedPieces: captured, targetColor: color),
              ],
            ),
          ),
          ChessClockWidget(
            playerName: name,
            playerElo: elo,
            timeSeconds: timeSeconds,
            isActive: isActiveTurn && boardState.status != GameStatus.checkmate,
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverModal(BuildContext context, ChessBoardState boardState, GameSession session) {
    String title;
    String subtitle;
    IconData icon;
    Color color;

    if (boardState.winner == session.userColor) {
      title = 'VICTORY!';
      subtitle = 'Checkmate! You won the game.';
      icon = Icons.emoji_events;
      color = AppColors.primaryGold;
    } else if (boardState.winner != null) {
      title = 'DEFEAT';
      subtitle = 'Your opponent won the match.';
      icon = Icons.sentiment_very_dissatisfied;
      color = Colors.redAccent;
    } else {
      title = 'DRAW';
      subtitle = 'Game ended in a draw.';
      icon = Icons.handshake;
      color = Colors.blueAccent;
    }

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: color).animate().scale(duration: 400.ms),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Return to Lobby'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGameModeTitle(GameType type) {
    switch (type) {
      case GameType.online:
        return 'Online Ranked Match';
      case GameType.wifiLan:
        return 'Local WiFi LAN Match';
      case GameType.privateRoom:
        return 'Private Room Code';
      case GameType.aiPractice:
        return 'Practice vs Stockfish AI';
      case GameType.localPassAndPlay:
        return 'Pass & Play';
    }
  }

  void _confirmResign(BuildContext context, ActiveGameNotifier notifier, PieceColor userColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Resign Game?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to surrender this match?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Resign', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.resign(userColor);
            },
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Exit Match?', style: TextStyle(color: Colors.white)),
        content: const Text('Exiting will forfeit the current game.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Stay', style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
