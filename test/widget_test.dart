import 'package:central_tower/game/central_tower_game.dart';
import 'package:central_tower/game/ui/game_over_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('game over overlay shows the run results', (
    WidgetTester tester,
  ) async {
    final CentralTowerGame game = CentralTowerGame();
    game.runState
      ..peakHeight = 4
      ..enemiesKilled = 7
      ..timeSurvived = 83;

    await tester.pumpWidget(MaterialApp(home: GameOverOverlay(game: game)));

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('01:23'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('RESTART'), findsOneWidget);
  });
}
