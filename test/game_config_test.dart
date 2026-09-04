import 'package:central_tower/game/game_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prototype pacing limits remain sensible', () {
    expect(
      GameConfig.enemyInitialSpawnInterval,
      greaterThan(GameConfig.enemyMinimumSpawnInterval),
    );
    expect(GameConfig.maxEnemies, lessThanOrEqualTo(30));
    expect(GameConfig.maxResources, lessThanOrEqualTo(20));
    expect(GameConfig.buildWoodCost, 3);
    expect(GameConfig.buildStoneCost, 3);
  });
}
