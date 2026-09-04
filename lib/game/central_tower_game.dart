import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'components/arena_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';
import 'components/resource_pickup.dart';
import 'components/tower_component.dart';
import 'game_config.dart';
import 'spawners/enemy_spawner.dart';
import 'spawners/resource_spawner.dart';
import 'state/run_state.dart';

class CentralTowerGame extends FlameGame {
  CentralTowerGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: GameConfig.logicalWidth,
          height: GameConfig.logicalHeight,
        ),
      );

  final RunState runState = RunState();
  final Random _random = Random();
  final Vector2 movementInput = Vector2.zero();
  final Set<EnemyComponent> enemies = <EnemyComponent>{};
  final Set<ResourcePickup> resources = <ResourcePickup>{};

  late PlayerComponent player;
  late TowerComponent tower;
  bool _building = false;
  bool _restarting = false;

  Vector2 get arenaCenter => Vector2.all(GameConfig.arenaSize / 2);

  @override
  Color backgroundColor() => const Color(0xff0b2017);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _startRun(resetState: true);
  }

  Future<void> _startRun({required bool resetState}) async {
    if (resetState) {
      runState.reset();
    }
    movementInput.setZero();
    enemies.clear();
    resources.clear();

    tower = TowerComponent(worldCenter: arenaCenter);
    player = PlayerComponent(startPosition: arenaCenter + Vector2(130, 0));

    await world.add(ArenaComponent());
    await world.add(tower);
    await world.add(player);
    await world.add(EnemySpawner());
    await world.add(ResourceSpawner());

    for (int i = 0; i < GameConfig.initialResourceCount; i += 1) {
      spawnResource(
        kind: i.isEven ? ResourceKind.wood : ResourceKind.stone,
        nearCenter: true,
      );
    }

    camera.follow(player, snap: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (runState.gameOver) {
      return;
    }
    runState.tick(dt);
    runState.setNearTower(
      player.position.distanceTo(tower.position) <= GameConfig.buildRange,
    );
  }

  void setMovement(Vector2 value) {
    if (runState.gameOver) {
      movementInput.setZero();
      return;
    }
    movementInput.setFrom(value.length2 > 1 ? value.normalized() : value);
  }

  void attack() => player.attack();

  void raiseShield() => player.raiseShield();

  void lowerShield() => player.lowerShield();

  Future<void> buildTower() async {
    if (_building || !runState.canBuild) {
      return;
    }
    _building = true;
    if (runState.spendBuildCost()) {
      await tower.addSegment();
    }
    _building = false;
  }

  void spawnMeleeCreep(Vector2 position) {
    if (runState.gameOver || enemies.length >= GameConfig.maxEnemies) {
      return;
    }
    final EnemyComponent enemy = EnemyComponent(spawnPosition: position);
    enemies.add(enemy);
    world.add(enemy);
  }

  void unregisterEnemy(EnemyComponent enemy) {
    enemies.remove(enemy);
  }

  void spawnResource({required ResourceKind kind, bool nearCenter = false}) {
    if (runState.gameOver || resources.length >= GameConfig.maxResources) {
      return;
    }

    Vector2 spawnPosition = arenaCenter;
    for (int attempt = 0; attempt < 10; attempt += 1) {
      const double inset = 70;
      final Vector2 candidate;
      if (nearCenter) {
        final double angle = _random.nextDouble() * pi * 2;
        final double distance = 190 + _random.nextDouble() * 260;
        candidate = arenaCenter + Vector2(cos(angle), sin(angle)) * distance;
      } else {
        candidate = Vector2(
          inset + _random.nextDouble() * (GameConfig.arenaSize - inset * 2),
          inset + _random.nextDouble() * (GameConfig.arenaSize - inset * 2),
        );
      }
      spawnPosition = candidate;
      if (candidate.distanceTo(arenaCenter) > 180) {
        break;
      }
    }

    final ResourcePickup pickup = ResourcePickup(
      kind: kind,
      value: 1 + _random.nextInt(3),
      position: spawnPosition,
    );
    resources.add(pickup);
    world.add(pickup);
  }

  void unregisterResource(ResourcePickup pickup) {
    resources.remove(pickup);
  }

  void checkForGameOver() {
    if (runState.gameOver || (player.health > 0 && tower.health > 0)) {
      return;
    }
    movementInput.setZero();
    runState.finishRun();
    overlays.add('gameOver');
    pauseEngine();
  }

  Future<void> restartRun() async {
    if (_restarting) {
      return;
    }
    _restarting = true;
    overlays.remove('gameOver');
    resumeEngine();
    world.removeAll(world.children.toList(growable: false));
    runState.reset();
    await _startRun(resetState: false);
    _restarting = false;
  }
}
