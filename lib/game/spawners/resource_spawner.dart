import 'dart:math';

import 'package:flame/components.dart';

import '../central_tower_game.dart';
import '../game_config.dart';
import '../state/run_state.dart';

class ResourceSpawner extends Component
    with HasGameReference<CentralTowerGame> {
  ResourceSpawner({Random? random}) : _random = random ?? Random();

  final Random _random;
  double _timeUntilSpawn = GameConfig.resourceSpawnInterval;

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

    if (game.resources.length < GameConfig.maxResources) {
      final ResourceKind kind = _random.nextBool()
          ? ResourceKind.wood
          : ResourceKind.stone;
      game.spawnResource(kind: kind);
    }
    _timeUntilSpawn = GameConfig.resourceSpawnInterval;
  }
}
