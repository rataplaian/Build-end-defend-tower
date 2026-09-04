import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../central_tower_game.dart';
import '../game_config.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({required this.game, super.key});

  final CentralTowerGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: game.runState,
        builder: (BuildContext context, Widget? child) {
          final state = game.runState;
          return Stack(
            children: <Widget>[
              Positioned(
                left: 12,
                right: 12,
                top: 8,
                child: _TopHud(game: game),
              ),
              if (state.canBuild)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 174,
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: game.buildTower,
                      icon: const Icon(Icons.construction),
                      label: const Text(
                        'BUILD  3 WOOD + 3 STONE',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xffd89c35),
                        foregroundColor: const Color(0xff201407),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 18,
                bottom: 18,
                child: MovementPad(onChanged: game.setMovement),
              ),
              Positioned(
                right: 18,
                bottom: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _ShieldButton(game: game),
                    const SizedBox(width: 12),
                    _ActionButton(
                      label: 'ATTACK',
                      icon: Icons.flash_on,
                      color: const Color(0xffd84c43),
                      enabled: !state.shieldActive && !state.gameOver,
                      onPressed: game.attack,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.game});

  final CentralTowerGame game;

  @override
  Widget build(BuildContext context) {
    final state = game.runState;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xcc101818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x88ffffff)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'WOOD: ${state.wood}',
                    style: const TextStyle(
                      color: Color(0xffffbd79),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STONE: ${state.stone}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xffe2e5e8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            _HealthLine(
              label: 'PLAYER',
              value: state.playerHealth,
              max: GameConfig.playerMaxHealth,
              color: const Color(0xff3488e8),
            ),
            const SizedBox(height: 4),
            _HealthLine(
              label: 'TOWER',
              value: state.towerHealth,
              max: state.towerMaxHealth,
              color: const Color(0xff62d26f),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('CURRENT HEIGHT: ${state.currentHeight}'),
                Text('PEAK HEIGHT: ${state.peakHeight}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthLine extends StatelessWidget {
  const _HealthLine({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double ratio = max <= 0 ? 0 : (value / max).clamp(0, 1).toDouble();
    return Row(
      children: <Widget>[
        SizedBox(
          width: 58,
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xff342f2f),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(
          width: 62,
          child: Text(
            '${value.ceil()}/${max.ceil()}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class MovementPad extends StatefulWidget {
  const MovementPad({required this.onChanged, super.key});

  final ValueChanged<Vector2> onChanged;

  @override
  State<MovementPad> createState() => _MovementPadState();
}

class _MovementPadState extends State<MovementPad> {
  static const double _size = 126;
  static const double _maxTravel = 38;
  Offset _knobOffset = Offset.zero;

  void _update(Offset localPosition) {
    final Offset raw = localPosition - const Offset(_size / 2, _size / 2);
    final double distance = raw.distance;
    final Offset clamped = distance > _maxTravel
        ? raw / distance * _maxTravel
        : raw;
    setState(() => _knobOffset = clamped);
    widget.onChanged(Vector2(clamped.dx / _maxTravel, clamped.dy / _maxTravel));
  }

  void _release() {
    setState(() => _knobOffset = Offset.zero);
    widget.onChanged(Vector2.zero());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (DragDownDetails details) => _update(details.localPosition),
      onPanUpdate: (DragUpdateDetails details) =>
          _update(details.localPosition),
      onPanEnd: (DragEndDetails details) => _release(),
      onPanCancel: _release,
      child: SizedBox.square(
        dimension: _size,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x77232f3a),
            border: Border.fromBorderSide(
              BorderSide(color: Color(0x99ffffff), width: 2),
            ),
          ),
          child: Center(
            child: Transform.translate(
              offset: _knobOffset,
              child: Container(
                width: 53,
                height: 53,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xcc4d94d8),
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0xddffffff), width: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Colors.black54, blurRadius: 7),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 26),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShieldButton extends StatelessWidget {
  const _ShieldButton({required this.game});

  final CentralTowerGame game;

  @override
  Widget build(BuildContext context) {
    final state = game.runState;
    final bool ready = state.shieldCooldownRemaining <= 0 && !state.gameOver;
    final String label = state.shieldActive
        ? 'BLOCK'
        : ready
        ? 'SHIELD'
        : '${state.shieldCooldownRemaining.toStringAsFixed(1)}s';
    final double readyProgress =
        1 -
        (state.shieldCooldownRemaining / GameConfig.shieldCooldown)
            .clamp(0, 1)
            .toDouble();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: ready ? (TapDownDetails details) => game.raiseShield() : null,
      onTapUp: (TapUpDetails details) => game.lowerShield(),
      onTapCancel: game.lowerShield,
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: state.shieldActive
              ? const Color(0xff58c9f2)
              : ready
              ? const Color(0xff327ca8)
              : const Color(0xff3e454a),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black54, blurRadius: 7),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.shield, size: 23),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: state.shieldActive
                      ? 1
                      : readyProgress.clamp(0, 1).toDouble(),
                  minHeight: 3,
                  backgroundColor: const Color(0x66000000),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
