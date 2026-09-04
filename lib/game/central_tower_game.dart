import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

import 'components/arena_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';
import 'components/resource_pickup.dart';
import 'components/tower_component.dart';
import 'game_config.dart';
import 'spawners/enemy_spawner.dart';
import 'spawners/resource_spawner.dart';
import 'state/run_state.dart';

class CentralTowerGame extends FlameGame with KeyboardEvents {
  CentralTowerGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: GameConfig.logicalWidth,
          height: GameConfig.logicalHeight,
        ),
      );

  final RunState runState = RunState();
  final Random _random = Random();
  final Vector2 _touchMovementInput = Vector2.zero();
  final Vector2 _keyboardMovementInput = Vector2.zero();
  final Vector2 mouseAimInput = Vector2.zero();
  final Set<EnemyComponent> enemies = <EnemyComponent>{};
  final Set<ResourcePickup> resources = <ResourcePickup>{};

  late PlayerComponent player;
  late TowerComponent tower;
  bool _building = false;
  bool _upgradingBag = false;
  bool _restarting = false;

  Vector2 get movementInput {
    final Vector2 combined = _touchMovementInput + _keyboardMovementInput;
    return combined.length2 > 1 ? combined.normalized() : combined;
  }

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
    _touchMovementInput.setZero();
    _keyboardMovementInput.setZero();
    mouseAimInput.setZero();
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
      spawnResource(kind: i.isEven ? ResourceKind.wood : ResourceKind.stone);
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
    final bool nearTower =
        player.position.distanceTo(tower.position) <=
        GameConfig.towerInteractionRange;
    runState.setNearTower(nearTower);
    if (nearTower) {
      runState.depositBag();
    }
  }

  void setMovement(Vector2 value) {
    if (runState.gameOver) {
      _touchMovementInput.setZero();
      return;
    }
    _touchMovementInput.setFrom(value.length2 > 1 ? value.normalized() : value);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final double horizontal =
        (keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0) -
        (keysPressed.contains(LogicalKeyboardKey.keyA) ? 1 : 0);
    final double vertical =
        (keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0) -
        (keysPressed.contains(LogicalKeyboardKey.keyW) ? 1 : 0);
    _keyboardMovementInput.setValues(horizontal, vertical);
    if (_keyboardMovementInput.length2 > 1) {
      _keyboardMovementInput.normalize();
    }
    return KeyEventResult.handled;
  }

  void setMouseAim(Vector2 canvasPosition) {
    if (!isLoaded || runState.gameOver) {
      return;
    }
    final Vector2 worldPosition = camera.globalToLocal(canvasPosition);
    mouseAimInput.setFrom(worldPosition - player.position);
    if (mouseAimInput.length2 > 0.001) {
      mouseAimInput.normalize();
    }
  }

  void clearMouseAim() => mouseAimInput.setZero();

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

  void upgradeBag() {
    if (_upgradingBag || !runState.canUpgradeBag) {
      return;
    }
    _upgradingBag = true;
    runState.spendBagUpgradeCost();
    _upgradingBag = false;
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

  void spawnResource({required ResourceKind kind}) {
    if (runState.gameOver || resources.length >= GameConfig.maxResources) {
      return;
    }

    Vector2 spawnPosition = arenaCenter;
    for (int attempt = 0; attempt < 20; attempt += 1) {
      const double pickupPadding = 45;
      const double spawnBand = 220;
      final double inset = GameConfig.arenaWallThickness + pickupPadding;
      final double angle = _random.nextDouble() * pi * 2;
      final double distance =
          GameConfig.resourceMinTowerDistance +
          _random.nextDouble() * spawnBand;
      final Vector2 candidate =
          arenaCenter + Vector2(cos(angle), sin(angle)) * distance;
      candidate.x = candidate.x
          .clamp(inset, GameConfig.arenaSize - inset)
          .toDouble();
      candidate.y = candidate.y
          .clamp(inset, GameConfig.arenaSize - inset)
          .toDouble();
      spawnPosition = candidate;
      if (candidate.distanceTo(arenaCenter) >=
          GameConfig.resourceMinTowerDistance) {
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
    _touchMovementInput.setZero();
    _keyboardMovementInput.setZero();
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
