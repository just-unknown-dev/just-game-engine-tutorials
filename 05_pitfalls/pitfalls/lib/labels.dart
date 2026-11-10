// Text over the game, for the demos. A label is placed at a world point:
// the camera looks at (0, 0) at a zoom of 1, so a world unit is a pixel
// and (0, 0) is the middle of the screen.
import 'package:flutter/material.dart';

typedef Label = ({String text, double x, double y, Color color});

Label label(String text, double x, double y, {Color color = Colors.white70}) =>
    (text: text, x: x, y: y, color: color);

/// [labels], each centred on its world point.
Widget labelsAt(List<Label> labels) => LayoutBuilder(
  builder: (context, size) => Stack(
    children: [
      for (final l in labels)
        Positioned(
          left: size.maxWidth / 2 + l.x,
          top: size.maxHeight / 2 + l.y,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Text(l.text, style: TextStyle(color: l.color, fontSize: 30)),
          ),
        ),
    ],
  ),
);
