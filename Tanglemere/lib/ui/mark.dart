import 'package:flutter/material.dart';

import '../web/play.dart';
import '../web/webs.dart';
import 'palette.dart';
import 'webview.dart';

/// The mark: the five posts a few threads in.
///
/// It is not a drawing of the game. The threads go through the same
/// code a finger goes through, and a test reads the weave still even.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get fourIn {
    var play = Play.of(Webs.at(0));
    play = play.weave(play.next!);
    play = play.weave(play.next!);
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onPanel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: WebView(
                        play: fourIn,
                        pointing: -1,
                        showWords: false,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
