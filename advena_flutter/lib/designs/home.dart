import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class EveningGradientBackground extends StatelessWidget {
  final Widget child;

  EveningGradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HexColor('#2D1C49'),
                HexColor('#483863'),
              ],
              stops: [0.1, 0.3],
            ),
          ),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: StarPainter(),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: FullMoonPainter(),
        ),
        child,
      ],
    );
  }
}

class StarPainter extends CustomPainter {
  final int numberOfStars;
  final double starSize;

  StarPainter({this.numberOfStars = 30, this.starSize = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    final random = Random();

    for (int i = 0; i < numberOfStars; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * starSize;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class FullMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint for the moon
    final moonPaint = Paint()..color = Colors.white.withOpacity(0.9);

    // Position and size of the moon
    final moonCenter = Offset(size.width * 0.8, size.height * 0.2);
    final moonRadius = 60.0;

    // Draw the full moon
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    // Define the paint for craters
    final craterPaint = Paint()..color = Colors.grey.withOpacity(0.6);

    // Draw some craters
    canvas.drawCircle(Offset(moonCenter.dx - 20, moonCenter.dy - 15),
        moonRadius * 0.15, craterPaint);
    canvas.drawCircle(Offset(moonCenter.dx + 15, moonCenter.dy - 25),
        moonRadius * 0.1, craterPaint);
    canvas.drawCircle(Offset(moonCenter.dx + 20, moonCenter.dy + 20),
        moonRadius * 0.12, craterPaint);
    canvas.drawCircle(Offset(moonCenter.dx - 10, moonCenter.dy + 25),
        moonRadius * 0.08, craterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//MORNING GRADIENT BACKGROUND

class MorningGradientBackground extends StatelessWidget {
  final Widget child;

  MorningGradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [HexColor("#7AC0FF"), HexColor("#BDE0FF")],
      stops: [0.1, 0.3],
    );

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: SunPainter(),
        ),
        CustomPaint(
          painter: BirdsPainter(),
          child: Container(), // Empty container to prevent clipping
        ),
        child,
      ],
    );
  }
}

class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint for the sun
    final sunPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.9)
      ..strokeWidth = 3.0;

    // Position and size of the sun
    final sunCenter = Offset(size.width * 0.8, size.height * 0.2);
    final sunRadius = 60.0;

    // Draw the sun (circle)
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Draw sun rays
    drawSunRays(canvas, sunCenter, sunRadius, sunPaint);
  }

  void drawSunRays(Canvas canvas, Offset center, double radius, Paint paint) {
    final double rayLength = radius * 1.2; // Length of sun rays
    final int rayCount = 12; // Number of sun rays
    final double angleStep = 2 * pi / rayCount;

    // Draw each sun ray
    for (int i = 0; i < rayCount; i++) {
      final double angle = i * angleStep;
      final double x1 = center.dx + radius * cos(angle);
      final double y1 = center.dy + radius * sin(angle);
      final double x2 = center.dx + rayLength * cos(angle);
      final double y2 = center.dy + rayLength * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BirdsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint for the birds
    final birdPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw the birds
    drawBird(canvas, Offset(size.width * 0.2, size.height * 0.3), birdPaint,
        pi / -3.5);
    drawBird(canvas, Offset(size.width * 0.5, size.height * 0.4), birdPaint,
        pi / -3.5);
    drawBird(canvas, Offset(size.width * 0.3, size.height * 0.5), birdPaint,
        pi / -3.5);
    drawBird(canvas, Offset(size.width * 0.6, size.height * 0.6), birdPaint,
        pi / -3.5);
  }

  void drawBird(
      Canvas canvas, Offset center, Paint paint, double rotationAngle) {
    final double size = 20.0; // Size of the bird
    final double halfSize = size / 2;

    final Path path = Path();

    // Draw the wing of the bird
    path.moveTo(center.dx - halfSize, center.dy + halfSize);
    path.quadraticBezierTo(center.dx, center.dy + size / 4,
        center.dx + halfSize, center.dy + halfSize);

    // Draw the body of the bird
    path.moveTo(center.dx - halfSize, center.dy - halfSize);
    path.quadraticBezierTo(center.dx + size / 4, center.dy,
        center.dx - halfSize, center.dy + halfSize);

    // Rotate the bird
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

  Widget navbarItems(Icon icon, String label, Color color){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Icon(icon.icon, color: color),
          Text(label, style: TextStyle(fontFamily: "WorkSans", color: color),)
        ],
      ),
    );
  }