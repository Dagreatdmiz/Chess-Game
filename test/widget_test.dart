import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_master_online/main.dart';

void main() {
  testWidgets('Chess Master App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChessMasterApp(),
      ),
    );

    expect(find.byType(ChessMasterApp), findsOneWidget);
  });
}

