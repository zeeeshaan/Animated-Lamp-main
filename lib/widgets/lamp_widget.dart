// lamp_widget.dart
import 'package:flutter/material.dart';
import 'lamp_painter.dart';

class LampWidget extends StatelessWidget {
  final bool isLampOn;
  final double brightness;
  final double pullDownValue;
  final Function(double) onPullUpdate;
  final Color color;

  const LampWidget({
    Key? key,
    required this.isLampOn,
    required this.brightness,
    required this.pullDownValue,
    required this.onPullUpdate,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.globalToLocal(details.globalPosition);
        final value = (position.dy / 300).clamp(0.0, 1.0);
        onPullUpdate(value);
      },
      onVerticalDragEnd: (_) {
        if (pullDownValue > 0.4) {
          onPullUpdate(0.6);
        } else {
          onPullUpdate(0.0);
        }
      },
      child: CustomPaint(
        size: const Size(300, 400),
        painter: LampPainter(
          isLampOn: isLampOn,
          brightness: brightness,
          pullDownValue: pullDownValue,
          color: color,
        ),
      ),
    );
  }
}