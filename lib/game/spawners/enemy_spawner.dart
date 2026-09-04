import 'dart:math';

import 'package:flame/components.dart';

import '../central_tower_game.dart';
import '../game_config.dart';

class EnemySpawner extends Component with HasGameReference<CentralTowerGame> {
  EnemySpawner({Random? random}) : _random = random ?? Random();

  final Random _random;
  double _timeUntilSpawn = 2.5;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.runState.gameOver) {
      return;
    }

    _timeUntilSpawn -= dt;
    if (_timeUntilSpawn > 0) {
      return;
    }

    if (game.enemies.length < GameConfig.maxEnemies) {
      game.spawnMeleeCreep(_randomEdgePosition());
    }
    _timeUntilSpawn = currentInterval;
  }

  double get currentInterval {
    final double progress =
        (game.runState.timeSurvived / GameConfig.enemySpawnRampSeconds)
            .clamp(0, 1)
            .toDouble();
    return GameConfig.enemyInitialSpawnInterval -
        (GameConfig.enemyInitialSpawnInterval -
                GameConfig.enemyMinimumSpawnInterval) *
            progress;
  }

  Vector2 _randomEdgePosition() {
    const double spawnPadding = 30;
    final double inset = GameConfig.arenaWallThickness + spawnPadding;
    final double along =
        inset + _random.nextDouble() * (GameConfig.arenaSize - inset * 2);
    switch (_random.nextInt(4)) {
      case 0:
        return Vector2(along, inset);
      case 1:
        return Vector2(GameConfig.arenaSize - inset, along);
      case 2:
        return Vector2(along, GameConfig.arenaSize - inset);
      default:
        return Vector2(inset, along);
    }
  }
}
