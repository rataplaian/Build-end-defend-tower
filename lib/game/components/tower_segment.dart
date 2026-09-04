import 'dart:ui';

import 'package:flame/components.dart';

class TowerSegment extends PositionComponent {
  TowerSegment({required this.index})
    : super(size: Vector2(index.isEven ? 86 : 74, 34), anchor: Anchor.center);

  final int index;

  @override
  void render(Canvas canvas) {
    final RRect block = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(7),
    );
    canvas.drawRRect(
      block,
      Paint()
        ..color = index.isEven
            ? const Color(0xff8a939b)
            : const Color(0xffaab1b7),
    );
    canvas.drawRRect(
      block,
      Paint()
        ..color = const Color(0xff3f484f)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      6,
      Paint()..color = const Color(0xff59636b),
    );
  }
}
