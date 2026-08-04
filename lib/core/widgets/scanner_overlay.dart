import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final double animationValue;

  ScannerOverlayPainter({
    required this.overlayColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final boxWidth = 280 + animationValue * 2;
    final boxHeight = 280 + animationValue * 2;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: boxWidth,
      height: boxHeight,
    );
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(AppRadius.xxl)));

    final path = Path.combine(PathOperation.difference, backgroundPath, holePath);
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.overlayColor != overlayColor;
  }
}
