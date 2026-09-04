import 'package:flutter/material.dart';

import '../central_tower_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({required this.game, super.key});

  final CentralTowerGame game;

  @override
  Widget build(BuildContext context) {
    final state = game.runState;
    final Duration survived = Duration(seconds: state.timeSurvived.floor());
    final String minutes = survived.inMinutes.toString().padLeft(2, '0');
    final String seconds = (survived.inSeconds % 60).toString().padLeft(2, '0');

    return ColoredBox(
      color: const Color(0xdd080b0d),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xff1d272c),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffe15a50), width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xffff6a5f),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ResultLine(
                    label: 'Peak Tower Height',
                    value: '${state.peakHeight}',
                  ),
                  _ResultLine(
                    label: 'Time Survived',
                    value: '$minutes:$seconds',
                  ),
                  _ResultLine(
                    label: 'Enemies Killed',
                    value: '${state.enemiesKilled}',
                  ),
                  const SizedBox(height: 26),
                  FilledButton.icon(
                    onPressed: game.restartRun,
                    icon: const Icon(Icons.refresh),
                    label: const Text('RESTART'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffe15a50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 180, child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
