import 'package:flutter/material.dart';
import '../../domain/engine/chess_move.dart';

class MoveHistoryList extends StatelessWidget {
  final List<ChessMove> moveHistory;

  const MoveHistoryList({
    super.key,
    required this.moveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final pairs = <List<ChessMove>>[];
    for (int i = 0; i < moveHistory.length; i += 2) {
      final whiteMove = moveHistory[i];
      final blackMove = i + 1 < moveHistory.length ? moveHistory[i + 1] : null;
      pairs.add([whiteMove, if (blackMove != null) blackMove]);
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pairs.length,
        itemBuilder: (context, index) {
          final pair = pairs[index];
          final moveNum = index + 1;
          final whiteSan = pair[0].sanNotation;
          final blackSan = pair.length > 1 ? pair[1].sanNotation : '';

          return Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$moveNum. ',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    TextSpan(
                      text: '$whiteSan ',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    if (blackSan.isNotEmpty)
                      TextSpan(
                        text: blackSan,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
