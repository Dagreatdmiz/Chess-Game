import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/chess_board_state.dart';
import '../../domain/models/match_history.dart';
import '../../providers/theme_provider.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  MatchResult? _filterResult;
  List<MatchHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final storage = ref.read(storageServiceProvider);
    final list = await storage.getMatchHistory();
    if (mounted) {
      setState(() {
        _history = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterResult == null
        ? _history
        : _history.where((m) => m.result == _filterResult).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Match History & Replay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Outcome Filter Chips
              Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Wins', MatchResult.win),
                  const SizedBox(width: 8),
                  _buildFilterChip('Losses', MatchResult.loss),
                  const SizedBox(width: 8),
                  _buildFilterChip('Draws', MatchResult.draw),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                    : filtered.isEmpty
                        ? const Center(child: Text('No match history recorded.', style: TextStyle(color: Colors.white54)))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              final match = filtered[index];
                              return _buildMatchTile(context, match);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, MatchResult? result) {
    final isSelected = _filterResult == result;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGold,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _filterResult = result),
    );
  }

  Widget _buildMatchTile(BuildContext context, MatchHistoryItem match) {
    Color badgeColor;
    String badgeText;

    switch (match.result) {
      case MatchResult.win:
        badgeColor = Colors.green;
        badgeText = 'VICTORY';
        break;
      case MatchResult.loss:
        badgeColor = Colors.redAccent;
        badgeText = 'DEFEAT';
        break;
      case MatchResult.draw:
        badgeColor = Colors.blueAccent;
        badgeText = 'DRAW';
        break;
    }

    return GlassCard(
      onTap: () => _openPgnReplayModal(context, match),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor),
            ),
            child: Text(
              badgeText,
              style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${match.opponentName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${match.openingName} • ${match.totalMoves} moves',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                match.durationText,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text('Replay', style: TextStyle(fontSize: 11, color: AppColors.primaryGold)),
                  Icon(Icons.play_arrow, size: 14, color: AppColors.primaryGold),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPgnReplayModal(BuildContext context, MatchHistoryItem match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PgnReplayViewer(match: match),
    );
  }
}

class _PgnReplayViewer extends StatefulWidget {
  final MatchHistoryItem match;

  const _PgnReplayViewer({required this.match});

  @override
  State<_PgnReplayViewer> createState() => _PgnReplayViewerState();
}

class _PgnReplayViewerState extends State<_PgnReplayViewer> {
  final ChessBoardState _board = ChessBoardState.initial();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${widget.match.opponentName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Opening: ${widget.match.openingName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Miniature Interactive Replay Board
            SizedBox(
              height: 300,
              child: ChessBoardWidget(
                boardState: _board,
                selectedSquare: null,
                validMoves: const [],
                onSquareTap: (_) {},
              ),
            ),

            const SizedBox(height: 16),

            // PGN Text Box
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.match.pgn,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }
}
