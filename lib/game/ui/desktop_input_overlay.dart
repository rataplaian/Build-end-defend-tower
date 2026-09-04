import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../central_tower_game.dart';

class DesktopInputOverlay extends StatefulWidget {
  const DesktopInputOverlay({required this.game, super.key});

  final CentralTowerGame game;

  @override
  State<DesktopInputOverlay> createState() => _DesktopInputOverlayState();
}

class _DesktopInputOverlayState extends State<DesktopInputOverlay> {
  bool _shieldHeld = false;

  void _aim(Offset position) {
    widget.game.setMouseAim(Vector2(position.dx, position.dy));
  }

  void _pointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }
    _aim(event.localPosition);
    if (event.buttons & kPrimaryMouseButton != 0) {
      widget.game.attack();
    }
    if (event.buttons & kSecondaryMouseButton != 0) {
      _shieldHeld = true;
      widget.game.raiseShield();
    }
  }

  void _pointerUp(PointerUpEvent event) {
    if (_shieldHeld) {
      _shieldHeld = false;
      widget.game.lowerShield();
    }
  }

  void _pointerMove(PointerMoveEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      _aim(event.localPosition);
    }
  }

  void _cancel(PointerCancelEvent event) {
    _shieldHeld = false;
    widget.game.lowerShield();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      onHover: (PointerHoverEvent event) => _aim(event.localPosition),
      onExit: (PointerExitEvent event) => widget.game.clearMouseAim(),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _pointerDown,
        onPointerMove: _pointerMove,
        onPointerUp: _pointerUp,
        onPointerCancel: _cancel,
        child: const SizedBox.expand(),
      ),
    );
  }
}
