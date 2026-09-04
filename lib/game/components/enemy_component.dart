import 'dart:ui';

import 'package:flame/components.dart';

import '../central_tower_game.dart';
import '../game_config.dart';

enum EnemyTarget { player, tower }

enum PreferredTarget { closest, player, tower }

class EnemyStats {
  const EnemyStats({
    required this.maxHealth,
    required this.movementSpeed,
    required this.damage,
    required this.attackRange,
    required this.attackCooldown,
    required this.targetSwitchCooldown,
    this.preferredTarget = PreferredTarget.closest,
  });

  final double maxHealth;
  final double movementSpeed;
  final double damage;
  final double attackRange;
  final double attackCooldown;
  final double targetSwitchCooldown;
  final PreferredTarget preferredTarget;
}

const EnemyStats meleeCreepStats = EnemyStats(
  maxHealth: GameConfig.enemyHealth,
  movementSpeed: GameConfig.enemySpeed,
  damage: GameConfig.enemyDamage,
  attackRange: GameConfig.enemyAttackRange,
  attackCooldown: GameConfig.enemyAttackCooldown,
  targetSwitchCooldown: GameConfig.enemyTargetSwitchCooldown,
);

class EnemyComponent extends PositionComponent
    with HasGameReference<CentralTowerGame> {
  EnemyComponent({required Vector2 spawnPosition, this.stats = meleeCreepStats})
    : health = stats.maxHealth,
      super(
        position: spawnPosition,
        size: Vector2.all(32),
        anchor: Anchor.center,
        priority: 15,
      );

  final EnemyStats stats;
  final double collisionRadius = 16;
  double health;

  EnemyTarget _target = EnemyTarget.tower;
  double _targetSwitchRemaining = 0;
  double _attackCooldownRemaining = 0;
  bool _dead = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.runState.gameOver || _dead) {
      return;
    }

    _attackCooldownRemaining = (_attackCooldownRemaining - dt)
        .clamp(0, double.infinity)
        .toDouble();
    _targetSwitchRemaining = (_targetSwitchRemaining - dt)
        .clamp(0, double.infinity)
        .toDouble();
    if (_targetSwitchRemaining <= 0) {
      _selectTarget();
      _targetSwitchRemaining = stats.targetSwitchCooldown;
    }

    final Vector2 targetPosition = _target == EnemyTarget.player
        ? game.player.position
        : game.tower.position;
    final double targetRadius = _target == EnemyTarget.player
        ? GameConfig.playerRadius
        : GameConfig.towerCollisionRadius;
    final Vector2 delta = targetPosition - position;
    final double contactDistance = stats.attackRange + targetRadius;

    if (delta.length > contactDistance) {
      if (delta.length2 > 0) {
        position.add(delta.normalized() * stats.movementSpeed * dt);
      }
      return;
    }

    if (_attackCooldownRemaining <= 0) {
      _attackCooldownRemaining = stats.attackCooldown;
      if (_target == EnemyTarget.player) {
        game.player.takeDamage(stats.damage, sourcePosition: position);
      } else {
        game.tower.takeDamage(stats.damage);
      }
    }
  }

  void _selectTarget() {
    if (stats.preferredTarget == PreferredTarget.player) {
      _target = EnemyTarget.player;
      return;
    }
    if (stats.preferredTarget == PreferredTarget.tower) {
      _target = EnemyTarget.tower;
      return;
    }

    final double playerDistance = position.distanceTo(game.player.position);
    final double towerDistance = position.distanceTo(game.tower.position);
    _target = playerDistance <= towerDistance
        ? EnemyTarget.player
        : EnemyTarget.tower;
  }

  void takeDamage(double amount) {
    if (_dead || game.runState.gameOver) {
      return;
    }
    health -= amount;
    if (health <= 0) {
      _dead = true;
      game.runState.recordKill();
      game.unregisterEnemy(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final Offset center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      collisionRadius,
      Paint()..color = const Color(0xffd84949),
    );
    canvas.drawCircle(
      center,
      collisionRadius,
      Paint()
        ..color = const Color(0xff6f1717)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final Vector2 targetPosition = _target == EnemyTarget.player
        ? game.player.position
        : game.tower.position;
    final Vector2 facing = targetPosition - position;
    if (facing.length2 > 0) {
      facing.normalize();
      canvas.drawCircle(
        center + Offset(facing.x, facing.y) * 9,
        3,
        Paint()..color = const Color(0xffffffff),
      );
    }

    final double healthRatio = (health / stats.maxHealth)
        .clamp(0, 1)
        .toDouble();
    canvas.drawRect(
      const Rect.fromLTWH(1, -8, 30, 5),
      Paint()..color = const Color(0xbb111111),
    );
    canvas.drawRect(
      Rect.fromLTWH(2, -7, 28 * healthRatio, 3),
      Paint()..color = const Color(0xff7bf17b),
    );
  }
}
