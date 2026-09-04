import 'package:central_tower/game/game_config.dart';
import 'package:central_tower/game/state/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunState', () {
    test('collects small wood and stone values', () {
      final RunState state = RunState();

      state.addResource(ResourceKind.wood, 2);
      state.addResource(ResourceKind.stone, 3);

      expect(state.wood, 2);
      expect(state.stone, 3);
    });

    test('spends exactly one build cost and records tower growth', () {
      final RunState state = RunState()
        ..addResource(ResourceKind.wood, 6)
        ..addResource(ResourceKind.stone, 6);

      expect(state.spendBuildCost(), isTrue);
      state.recordBuild(GameConfig.towerHealthPerSegment);

      expect(state.wood, 3);
      expect(state.stone, 3);
      expect(state.currentHeight, 2);
      expect(state.peakHeight, 2);
      expect(
        state.towerMaxHealth,
        GameConfig.towerBaseHealth + GameConfig.towerHealthPerSegment,
      );
    });

    test('cannot build without both resources', () {
      final RunState state = RunState()
        ..addResource(ResourceKind.wood, 10)
        ..addResource(ResourceKind.stone, 2);

      expect(state.spendBuildCost(), isFalse);
      expect(state.wood, 10);
      expect(state.stone, 2);
    });

    test('reset clears run results and restores base health', () {
      final RunState state = RunState()
        ..addResource(ResourceKind.wood, 3)
        ..recordKill()
        ..finishRun();

      state.reset();

      expect(state.wood, 0);
      expect(state.enemiesKilled, 0);
      expect(state.gameOver, isFalse);
      expect(state.playerHealth, GameConfig.playerMaxHealth);
      expect(state.towerHealth, GameConfig.towerBaseHealth);
    });
  });
}
