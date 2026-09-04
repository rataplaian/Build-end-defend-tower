import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

class SwordSlash extends PositionComponent {
  SwordSlash({required Vector2 origin, required Vector2 direction})
    : super(
        position: origin,
        size: Vector2.all(110),
        anchor: Anchor.center,
        angle: math.atan2(direction.y, direction.x),
        priority: 30,
      );

  double _life = 0.16;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final Paint slashPaint = Paint()
      ..color = const Color(0xddfff3ad)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final Rect arcRect = Rect.fromCircle(
      center: Offset(size.x / 2, size.y / 2),
      radius: 43,
    );
    canvas.drawArc(arcRect, -math.pi / 3, math.pi * 2 / 3, false, slashPaint);
  }
}
