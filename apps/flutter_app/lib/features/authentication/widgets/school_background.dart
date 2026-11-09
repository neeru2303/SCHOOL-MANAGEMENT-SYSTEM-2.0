import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SchoolBackground extends StatefulWidget {
  final Widget child;

  const SchoolBackground({super.key, required this.child});

  @override
  State<SchoolBackground> createState() => _SchoolBackgroundState();
}

class _SchoolBackgroundState extends State<SchoolBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SchoolBackgroundPainter(_controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SchoolBackgroundPainter extends CustomPainter {
  final double progress;

  _SchoolBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF07152F), Color(0xFF102D5C), Color(0xFF0A1B39)],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    _drawGlow(canvas, Offset(size.width * 0.15, size.height * 0.2), 230);

    _drawGlow(canvas, Offset(size.width * 0.85, size.height * 0.8), 280);

    _drawGrid(canvas, size);
    _drawEducationalSymbols(canvas, size);
    _drawFloatingDots(canvas, size);
  }

  void _drawGlow(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.20),
          AppColors.primaryLight.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    const gap = 45.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawEducationalSymbols(Canvas canvas, Size size) {
    final symbols = [
      ('π', 0.08, 0.17, 34.0),
      ('√', 0.87, 0.16, 38.0),
      ('∑', 0.92, 0.62, 32.0),
      ('△', 0.10, 0.78, 40.0),
      ('a²+b²', 0.76, 0.87, 23.0),
      ('E=mc²', 0.24, 0.91, 21.0),
      ('÷', 0.55, 0.12, 32.0),
      ('+', 0.42, 0.83, 30.0),
      ('✎', 0.94, 0.36, 28.0),
      ('✦', 0.05, 0.48, 25.0),
    ];

    for (final item in symbols) {
      final x = size.width * (item.$2);
      final y = size.height * (item.$3);
      final fontSize = item.$4;

      final movement = math.sin((progress * math.pi * 2) + x / 100) * 8;

      final textPainter = TextPainter(
        text: TextSpan(
          text: item.$1,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.13),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x, y + movement));
    }

    _drawGeometry(canvas, size);
  }

  void _drawGeometry(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final triangle = Path()
      ..moveTo(size.width * 0.16, size.height * 0.30)
      ..lineTo(size.width * 0.20, size.height * 0.22)
      ..lineTo(size.width * 0.24, size.height * 0.30)
      ..close();

    canvas.drawPath(triangle, paint);

    canvas.drawCircle(Offset(size.width * 0.83, size.height * 0.30), 25, paint);

    canvas.drawLine(
      Offset(size.width * 0.83, size.height * 0.27),
      Offset(size.width * 0.83, size.height * 0.33),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.80, size.height * 0.30),
      Offset(size.width * 0.86, size.height * 0.30),
      paint,
    );
  }

  void _drawFloatingDots(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.accent.withValues(alpha: 0.45);

    for (int i = 0; i < 35; i++) {
      final x = ((i * 137.0) % size.width);
      final baseY = ((i * 83.0) % size.height);

      final y =
          (baseY + math.sin(progress * math.pi * 2 + i) * 12) % size.height;

      canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 2 : 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SchoolBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
