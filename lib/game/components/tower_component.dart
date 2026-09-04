import 'dart:ui';

import 'package:flame/components.dart';

import '../central_tower_game.dart';
import '../game_config.dart';
import 'tower_segment.dart';

class TowerComponent extends PositionComponent
    with HasGameReference<CentralTowerGame> {
  TowerComponent({required Vector2 worldCenter})
    : super(
        position: worldCenter,
        size: Vector2(140, 220),
        anchor: Anchor.center,
        priority: 10,
      );

  final List<TowerSegment> segments = <TowerSegment>[];
  double health = GameConfig.towerBaseHealth;
  double maxHealth = GameConfig.towerBaseHealth;

  int get segmentCount => segments.length;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _appendVisualSegment();
  }

  Future<void> addSegment() async {
    maxHealth += GameConfig.towerHealthPerSegment;
    health = (health + GameConfig.towerHealthPerSegment)
        .clamp(0, maxHealth)
        .toDouble();
    await _appendVisualSegment();
    game.runState.recordBuild(GameConfig.towerHealthPerSegment);
  }

  Future<void> _appendVisualSegment() async {
    final TowerSegment segment = TowerSegment(index: segments.length);
    segment.position = Vector2(size.x / 2, size.y / 2 - segments.length * 13);
    segments.add(segment);
    await add(segment);
  }

  void takeDamage(double amount) {
    if (game.runState.gameOver) {
      return;
    }
    health = (health - amount).clamp(0, maxHealth).toDouble();
    game.runState.setTowerHealth(health);
    game.checkForGameOver();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double top = size.y / 2 - (segments.length - 1) * 13 - 32;
    const double barWidth = 104;
    const double barHeight = 10;
    final double left = (size.x - barWidth) / 2;
    final double ratio = maxHealth <= 0 ? 0 : health / maxHealth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xaa111111),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2, top + 2, (barWidth - 4) * ratio, barHeight - 4),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xff62d26f),
    );
  }
}
