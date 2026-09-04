import 'dart:math' as math;
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
        size: Vector2.all(58),
        anchor: Anchor.center,
        priority: 15,
      );

  final EnemyStats stats;
  final double collisionRadius = 19;
  final Vector2 _facing = Vector2(0, 1);
  double health;

  EnemyTarget _target = EnemyTarget.tower;
  double _targetSwitchRemaining = 0;
  double _attackCooldownRemaining = 0;
  double _attackPulse = 0;
  double _animationTime = 0;
  bool _dead = false;
  late final SpriteComponent _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = SpriteComponent(
      sprite: await game.loadSprite('melee_creep.png'),
      size: size.clone(),
      position: size / 2,
      anchor: Anchor.center,
    );
    await add(_sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.runState.gameOver || _dead) {
      return;
    }

    _attackCooldownRemaining = (_attackCooldownRemaining - dt)
        .clamp(0, double.infinity)
        .toDouble();
    _attackPulse = (_attackPulse - dt).clamp(0, double.infinity).toDouble();
    _animationTime += dt;
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
    if (delta.length2 > 0.001) {
      _facing.setFrom(delta.normalized());
      _sprite.angle = math.atan2(_facing.y, _facing.x) - math.pi / 2;
    }
    final double bob = math.sin(_animationTime * 7) * 1.5;
    final double attackScale = _attackPulse > 0 ? 1.12 : 1;
    _sprite
      ..position.setValues(size.x / 2, size.y / 2 + bob)
      ..scale.setAll(attackScale);
    final double contactDistance = stats.attackRange + targetRadius;

    if (delta.length > contactDistance) {
      if (delta.length2 > 0) {
        position.add(delta.normalized() * stats.movementSpeed * dt);
      }
      return;
    }

    if (_attackCooldownRemaining <= 0) {
      _attackCooldownRemaining = stats.attackCooldown;
      _attackPulse = 0.14;
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
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 18),
        width: 34,
        height: 12,
      ),
      Paint()..color = const Color(0x66000000),
    );

    final double healthRatio = (health / stats.maxHealth)
        .clamp(0, 1)
        .toDouble();
    canvas.drawRect(
      Rect.fromLTWH(7, -5, size.x - 14, 6),
      Paint()..color = const Color(0xbb111111),
    );
    canvas.drawRect(
      Rect.fromLTWH(8, -4, (size.x - 16) * healthRatio, 4),
      Paint()..color = const Color(0xff7bf17b),
    );
  }
}
