import 'package:central_tower/game/game_config.dart';
import 'package:central_tower/game/state/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunState', () {
    test('collects into the bag and deposits at the tower', () {
      final RunState state = RunState();

      expect(state.collectResource(ResourceKind.wood, 2), 2);
      expect(state.collectResource(ResourceKind.stone, 3), 3);

      expect(state.wood, 0);
      expect(state.stone, 0);
      expect(state.carriedTotal, 5);

      expect(state.depositBag(), isTrue);
      expect(state.wood, 2);
      expect(state.stone, 3);
      expect(state.carriedTotal, 0);
    });

    test('bag accepts a partial pickup when almost full', () {
      final RunState state = RunState();

      state.collectResource(ResourceKind.wood, 5);
      expect(state.collectResource(ResourceKind.stone, 3), 1);

      expect(state.carriedWood, 5);
      expect(state.carriedStone, 1);
      expect(state.bagFull, isTrue);
    });

    test('spends exactly one build cost and records tower growth', () {
      final RunState state = RunState()
        ..collectResource(ResourceKind.wood, 3)
        ..collectResource(ResourceKind.stone, 3)
        ..depositBag();

      expect(state.spendBuildCost(), isTrue);
      state.recordBuild(GameConfig.towerHealthPerSegment);

      expect(state.wood, 0);
      expect(state.stone, 0);
      expect(state.currentHeight, 2);
      expect(state.peakHeight, 2);
      expect(
        state.towerMaxHealth,
        GameConfig.towerBaseHealth + GameConfig.towerHealthPerSegment,
      );
    });

    test('cannot build without both resources', () {
      final RunState state = RunState()
        ..collectResource(ResourceKind.wood, 4)
        ..collectResource(ResourceKind.stone, 2)
        ..depositBag();

      expect(state.spendBuildCost(), isFalse);
      expect(state.wood, 4);
      expect(state.stone, 2);
    });

    test(
      'bag upgrades increase capacity and make the next upgrade costlier',
      () {
        final RunState state = RunState()
          ..collectResource(ResourceKind.wood, 3)
          ..collectResource(ResourceKind.stone, 3)
          ..depositBag()
          ..collectResource(ResourceKind.wood, 1)
          ..collectResource(ResourceKind.stone, 1)
          ..depositBag();

        expect(state.spendBagUpgradeCost(), isTrue);
        expect(
          state.bagCapacity,
          GameConfig.initialBagCapacity + GameConfig.bagCapacityPerUpgrade,
        );
        expect(state.bagUpgradeWoodCost, 6);
        expect(state.bagUpgradeStoneCost, 6);
      },
    );

    test('reset clears run results and restores base health', () {
      final RunState state = RunState()
        ..collectResource(ResourceKind.wood, 3)
        ..recordKill()
        ..finishRun();

      state.reset();

      expect(state.wood, 0);
      expect(state.carriedWood, 0);
      expect(state.bagCapacity, GameConfig.initialBagCapacity);
      expect(state.enemiesKilled, 0);
      expect(state.gameOver, isFalse);
      expect(state.playerHealth, GameConfig.playerMaxHealth);
      expect(state.towerHealth, GameConfig.towerBaseHealth);
    });
  });
}
