import 'dart:ui';

import 'package:flame/components.dart';

import '../game_config.dart';

class ArenaComponent extends PositionComponent {
  ArenaComponent()
    : super(size: Vector2.all(GameConfig.arenaSize), priority: -100);

  final Paint _groundPaint = Paint()..color = const Color(0xff173d2b);
  final Paint _gridPaint = Paint()
    ..color = const Color(0x143fffff)
    ..strokeWidth = 2;
  final Paint _wallPaint = Paint()..color = const Color(0xff26352f);
  final Paint _wallEdgePaint = Paint()
    ..color = const Color(0xff9bb57e)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  @override
  void render(Canvas canvas) {
    final Rect arena = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(arena, _groundPaint);

    const double gridSize = 120;
    for (double offset = gridSize; offset < size.x; offset += gridSize) {
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.y), _gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.x, offset), _gridPaint);
    }
    final double wall = GameConfig.arenaWallThickness;
    final Path walls = Path()
      ..addRect(arena)
      ..addRect(Rect.fromLTWH(wall, wall, size.x - wall * 2, size.y - wall * 2))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(walls, _wallPaint);
    canvas.drawRect(
      Rect.fromLTWH(wall, wall, size.x - wall * 2, size.y - wall * 2),
      _wallEdgePaint,
    );

    const double postSize = 42;
    for (final Offset corner in <Offset>[
      const Offset(0, 0),
      Offset(size.x - postSize, 0),
      Offset(0, size.y - postSize),
      Offset(size.x - postSize, size.y - postSize),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(corner.dx, corner.dy, postSize, postSize),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xff60705e),
      );
    }
  }
}
