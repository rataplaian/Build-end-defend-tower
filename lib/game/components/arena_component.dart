import 'dart:ui';

import 'package:flame/components.dart';

import '../game_config.dart';

class ArenaComponent extends PositionComponent {
  ArenaComponent()
    : super(size: Vector2.all(GameConfig.arenaSize), priority: -100);

  final Paint _groundPaint = Paint()..color = const Color(0xff173d2b);
  final Paint _gridPaint = Paint()
    ..color = const Color(0x183fffff)
    ..strokeWidth = 2;
  final Paint _borderPaint = Paint()
    ..color = const Color(0xff80a070)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;

  @override
  void render(Canvas canvas) {
    final Rect arena = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(arena, _groundPaint);

    const double gridSize = 120;
    for (double offset = gridSize; offset < size.x; offset += gridSize) {
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.y), _gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.x, offset), _gridPaint);
    }
    canvas.drawRect(arena, _borderPaint);
  }
}
