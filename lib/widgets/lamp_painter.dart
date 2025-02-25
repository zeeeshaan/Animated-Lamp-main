// lamp_painter.dart
import 'package:flutter/material.dart';

class LampPainter extends CustomPainter {
  final bool isLampOn;
  final double brightness;
  final double pullDownValue;
  final Color color;

  LampPainter({
    required this.isLampOn,
    required this.brightness,
    required this.pullDownValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Cable properties
    final cablePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Cable dimensions
    final double minCableLength = 40;
    final double maxCableLength = 160;
    final double cableLength = minCableLength + (maxCableLength - minCableLength) * pullDownValue;

    // Add a slight curve to the cable for realism
    final cablePath = Path();
    final controlPoint1 = Offset(size.width / 2 - 20 * pullDownValue, cableLength / 3);
    final controlPoint2 = Offset(size.width / 2 + 20 * pullDownValue, cableLength * 2 / 3);

    cablePath.moveTo(size.width / 2, 0);
    cablePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        size.width / 2, cableLength
    );
    canvas.drawPath(cablePath, cablePaint);

    // Draw pull handle with metallic effect
    final handleGradient = RadialGradient(
      colors: [
        Colors.grey.shade300,
        Colors.grey.shade400,
        Colors.grey.shade300,
      ],
    );

    final handlePaint = Paint()
      ..shader = handleGradient.createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, cableLength),
          radius: 10,
        ),
      );

    final handleShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final handleCenter = Offset(size.width / 2, cableLength);
    canvas.drawCircle(handleCenter, 10, handleShadowPaint);
    canvas.drawCircle(handleCenter, 10, handlePaint);
    canvas.drawCircle(handleCenter, 8, cablePaint);

    // Top fixture with metallic effect
    final fixtureGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey.shade400,
        Colors.grey.shade300,
        Colors.grey.shade400,
      ],
    );

    final fixturePaint = Paint()
      ..shader = fixtureGradient.createShader(
        Rect.fromLTWH(
          (size.width - 24.0) / 2,
          cableLength,
          24.0,
          12.0,
        ),
      );

    final fixtureShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final fixtureRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - 24.0) / 2,
        cableLength,
        24.0,
        12.0,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(fixtureRect, fixtureShadowPaint);
    canvas.drawRRect(fixtureRect, fixturePaint);

    // Lamp shade with enhanced metallic effect
    final lampShadeHeight = 100.0;
    final lampShadeTopWidth = 60.0;
    final lampShadeBottomWidth = 120.0;
    final lampTop = cableLength + 12.0;

    final lampPath = Path();
    final leftTop = Offset(size.width / 2 - lampShadeTopWidth / 2, lampTop);
    final rightTop = Offset(size.width / 2 + lampShadeTopWidth / 2, lampTop);
    final leftBottom = Offset(size.width / 2 - lampShadeBottomWidth / 2, lampTop + lampShadeHeight);
    final rightBottom = Offset(size.width / 2 + lampShadeBottomWidth / 2, lampTop + lampShadeHeight);

    lampPath.moveTo(leftTop.dx, leftTop.dy);
    lampPath.lineTo(rightTop.dx, rightTop.dy);
    lampPath.lineTo(rightBottom.dx, rightBottom.dy);
    lampPath.lineTo(leftBottom.dx, leftBottom.dy);
    lampPath.close();

    // Create a more sophisticated metallic effect for the lamp shade
    final lampGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade400,
        Colors.grey.shade300,
        Colors.grey.shade400,
        Colors.grey.shade300,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final lampPaint = Paint()
      ..shader = lampGradient.createShader(lampPath.getBounds());

    // Enhanced shadow effect
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(lampPath, shadowPaint);
    canvas.drawPath(lampPath, lampPaint);

    // Add a subtle rim highlight
    final rimPath = Path()
      ..moveTo(leftTop.dx, leftTop.dy)
      ..lineTo(rightTop.dx, rightTop.dy)
      ..lineTo(rightBottom.dx, rightBottom.dy)
      ..lineTo(leftBottom.dx, leftBottom.dy);

    canvas.drawPath(
      rimPath,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Light effect when lamp is on
    if (isLampOn) {
      final lightCenter = Offset(size.width / 2, lampTop + lampShadeHeight);
      final lightRadius = 250.0;
      final alpha = (brightness * 180).toInt();

      // Outer glow with custom color
      final outerGlow = Path()
        ..moveTo(leftBottom.dx, leftBottom.dy)
        ..lineTo(rightBottom.dx, rightBottom.dy)
        ..lineTo(rightBottom.dx + lightRadius, lightCenter.dy + lightRadius)
        ..lineTo(leftBottom.dx - lightRadius, lightCenter.dy + lightRadius)
        ..close();

      final glowGradient = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.0,
        colors: [
          color.withAlpha(alpha),
          color.withAlpha((alpha * 0.7).toInt()),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      );

      final glowPaint = Paint()
        ..shader = glowGradient.createShader(outerGlow.getBounds());

      canvas.drawPath(outerGlow, glowPaint);

      // Inner light source
      final innerGlow = RadialGradient(
        colors: [
          Colors.white.withAlpha(alpha),
          color.withAlpha((alpha * 0.8).toInt()),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, lampTop + lampShadeHeight * 0.7),
        radius: lampShadeTopWidth / 1.5,
      ));

      canvas.drawCircle(
        Offset(size.width / 2, lampTop + lampShadeHeight * 0.7),
        lampShadeTopWidth / 1.5,
        Paint()..shader = innerGlow,
      );

      // Add ambient light reflection on the lamp shade
      final ambientPath = Path()
        ..moveTo(leftTop.dx, leftTop.dy)
        ..lineTo(rightTop.dx, rightTop.dy)
        ..lineTo(rightBottom.dx, rightBottom.dy)
        ..lineTo(leftBottom.dx, leftBottom.dy)
        ..close();

      canvas.drawPath(
        ambientPath,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.0, 0.5),
            radius: 1.0,
            colors: [
              color.withAlpha((alpha * 0.2).toInt()),
              Colors.transparent,
            ],
          ).createShader(ambientPath.getBounds()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LampPainter oldDelegate) {
    return oldDelegate.isLampOn != isLampOn ||
        oldDelegate.brightness != brightness ||
        oldDelegate.pullDownValue != pullDownValue ||
        oldDelegate.color != color;
  }}