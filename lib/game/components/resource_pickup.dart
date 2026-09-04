import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../central_tower_game.dart';
import '../state/run_state.dart';

class ResourcePickup extends PositionComponent
    with HasGameReference<CentralTowerGame> {
  ResourcePickup({
    required this.kind,
    required this.value,
    required Vector2 position,
  }) : super(
         position: position,
         size: Vector2.all(24),
         anchor: Anchor.center,
         priority: 4,
       );

  final ResourceKind kind;
  int value;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.runState.gameOver || isRemoving) {
      return;
    }
    if (position.distanceTo(game.player.position) <= 31) {
      final int collected = game.runState.collectResource(kind, value);
      value -= collected;
      if (value <= 0) {
        game.unregisterResource(this);
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final Paint fill = Paint()
      ..color = kind == ResourceKind.wood
          ? const Color(0xff9c5b2e)
          : const Color(0xffc3c8cc);
    final Paint outline = Paint()
      ..color = const Color(0xff2a2522)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (kind == ResourceKind.wood) {
      final RRect log = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 5, size.x - 4, size.y - 10),
        const Radius.circular(5),
      );
      canvas.drawRRect(log, fill);
      canvas.drawRRect(log, outline);
      canvas.drawLine(const Offset(8, 6), const Offset(8, 18), outline);
    } else {
      final Path rock = Path()
        ..moveTo(4, 18)
        ..lineTo(2, 10)
        ..lineTo(8, 3)
        ..lineTo(18, 4)
        ..lineTo(23, 12)
        ..lineTo(18, 21)
        ..close();
      canvas.drawPath(rock, fill);
      canvas.drawPath(rock, outline);
    }

    final TextPainter label = TextPainter(
      text: TextSpan(
        text: '$value',
        style: const TextStyle(
          color: Color(0xffffffff),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset((size.x - label.width) / 2, -13));
  }
}
