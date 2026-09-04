import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/central_tower_game.dart';
import 'game/ui/desktop_input_overlay.dart';
import 'game/ui/game_over_overlay.dart';
import 'game/ui/hud_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const CentralTowerApp());
}

class CentralTowerApp extends StatelessWidget {
  const CentralTowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Build & Defend Tower',
      theme: ThemeData.dark(useMaterial3: true),
      home: GameWidget<CentralTowerGame>(
        game: CentralTowerGame(),
        initialActiveOverlays: const <String>['desktopInput', 'hud'],
        overlayBuilderMap:
            <String, Widget Function(BuildContext, CentralTowerGame)>{
              'hud': (BuildContext context, CentralTowerGame game) =>
                  HudOverlay(game: game),
              'desktopInput': (BuildContext context, CentralTowerGame game) =>
                  DesktopInputOverlay(game: game),
              'gameOver': (BuildContext context, CentralTowerGame game) =>
                  GameOverOverlay(game: game),
            },
      ),
    );
  }
}
