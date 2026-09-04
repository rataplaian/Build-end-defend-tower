import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../central_tower_game.dart';
import '../game_config.dart';
import '../state/shield_controller.dart';
import 'sword_slash.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<CentralTowerGame> {
  PlayerComponent({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2.all(GameConfig.playerRadius * 2),
        anchor: Anchor.center,
        priority: 20,
      );

  final Vector2 facing = Vector2(0, -1);
  final ShieldController shield = ShieldController(
    maxDuration: GameConfig.shieldMaxDuration,
    cooldownDuration: GameConfig.shieldCooldown,
  );
  double health = GameConfig.playerMaxHealth;
  double _attackCooldownRemaining = 0;

  bool get shieldActive => shield.isActive;
  double get shieldCooldownRemaining => shield.cooldownRemaining;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.runState.gameOver) {
      return;
    }

    _attackCooldownRemaining = (_attackCooldownRemaining - dt)
        .clamp(0, double.infinity)
        .toDouble();
    shield.update(dt);

    final Vector2 input = game.movementInput;
    if (game.mouseAimInput.length2 > 0.0025) {
      facing.setFrom(game.mouseAimInput);
    }
    if (input.length2 > 0.0025) {
      if (game.mouseAimInput.length2 <= 0.0025) {
        facing.setFrom(input.normalized());
      }
      final Vector2 candidate = position + input * GameConfig.playerSpeed * dt;
      _moveWithinArenaAndAroundTower(candidate);
    }

    game.runState.setShieldStatus(
      active: shield.isActive,
      cooldown: shield.cooldownRemaining,
    );
  }

  void _moveWithinArenaAndAroundTower(Vector2 candidate) {
    final double min = GameConfig.arenaWallThickness + GameConfig.playerRadius;
    final double max = GameConfig.arenaSize - min;
    candidate.x = candidate.x.clamp(min, max).toDouble();
    candidate.y = candidate.y.clamp(min, max).toDouble();

    final Vector2 fromTower = candidate - game.tower.position;
    final double requiredDistance =
        GameConfig.towerCollisionRadius + GameConfig.playerRadius;
    if (fromTower.length < requiredDistance) {
      if (fromTower.length2 == 0) {
        fromTower.setValues(1, 0);
      }
      candidate =
          game.tower.position + fromTower.normalized() * requiredDistance;
    }
    position.setFrom(candidate);
  }

  void attack() {
    if (game.runState.gameOver ||
        shield.isActive ||
        _attackCooldownRemaining > 0) {
      return;
    }
    _attackCooldownRemaining = GameConfig.playerAttackCooldown;
    game.world.add(
      SwordSlash(origin: position.clone(), direction: facing.clone()),
    );

    for (final enemy in game.enemies.toList(growable: false)) {
      final Vector2 delta = enemy.position - position;
      final double hitDistance =
          GameConfig.playerAttackRange + enemy.collisionRadius;
      if (delta.length > hitDistance || delta.length2 == 0) {
        continue;
      }
      if (facing.dot(delta.normalized()) >= 0.35) {
        enemy.takeDamage(GameConfig.playerAttackDamage);
      }
    }
  }

  void raiseShield() {
    if (game.runState.gameOver || !shield.tryActivate()) {
      return;
    }
    game.runState.setShieldStatus(active: shield.isActive, cooldown: 0);
  }

  void lowerShield() {
    if (!shield.isActive) {
      return;
    }
    shield.lower();
    game.runState.setShieldStatus(
      active: false,
      cooldown: shield.cooldownRemaining,
    );
  }

  void takeDamage(double amount, {required Vector2 sourcePosition}) {
    if (game.runState.gameOver) {
      return;
    }

    final Vector2 incoming = sourcePosition - position;
    final bool blocked =
        shield.isActive &&
        incoming.length2 > 0 &&
        facing.dot(incoming.normalized()) >= 0.25;
    if (blocked) {
      return;
    }

    health = (health - amount).clamp(0, GameConfig.playerMaxHealth).toDouble();
    game.runState.setPlayerHealth(health);
    game.checkForGameOver();
  }

  @override
  void render(Canvas canvas) {
    final Offset center = Offset(size.x / 2, size.y / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center - Offset(facing.x, facing.y) * 13,
          width: 22,
          height: 25,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xffb77b3d),
    );
    canvas.drawCircle(
      center,
      GameConfig.playerRadius,
      Paint()..color = const Color(0xff3488e8),
    );
    canvas.drawCircle(
      center,
      GameConfig.playerRadius,
      Paint()
        ..color = const Color(0xffcfe7ff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawLine(
      center,
      center + Offset(facing.x, facing.y) * 24,
      Paint()
        ..color = const Color(0xffffffff)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    if (game.runState.carriedTotal > 0 && !game.runState.nearTower) {
      final Vector2 towerDirection = game.tower.position - position;
      if (towerDirection.length2 > 0) {
        towerDirection.normalize();
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(math.atan2(towerDirection.y, towerDirection.x));
        final Path homeArrow = Path()
          ..moveTo(43, 0)
          ..lineTo(31, -8)
          ..lineTo(34, 0)
          ..lineTo(31, 8)
          ..close();
        canvas.drawPath(
          homeArrow,
          Paint()..color = const Color(0xffffd65c),
        );
        canvas.restore();
      }
    }

    if (shield.isActive) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(math.atan2(facing.y, facing.x));
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 29),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xff82dcff)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }
  }
}
