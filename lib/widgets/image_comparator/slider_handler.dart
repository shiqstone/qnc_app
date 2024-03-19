import 'package:flutter/material.dart';

class SliderHandler extends StatelessWidget {
  final double position; // Position of the slider handle.
  final double? height;

  SliderHandler({required this.position, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: SliderHandlerPainter(position, this.height ?? MediaQuery.of(context).size.height / 5 * 3),
      ),
    );
  }
}

class SliderHandlerPainter extends CustomPainter {
  final double position;
  final double height;

  SliderHandlerPainter(this.position, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Draw the vertical line.
    canvas.drawLine(
      Offset(size.width / 2 - 1, -height / 2 + 1),
      Offset(size.width / 2 + 1, height / 2 - 1),
      paint,
    );

    // Draw the circle.
    paint
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final double circleRadius = 20;
    final Offset circleCenter = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // Clip the left or right half of the circle.
    final bool shouldClipLeftSide = position > 0.5;
    final Rect clipRect = shouldClipLeftSide
        ? Rect.fromLTWH(
            0,
            circleCenter.dy - circleRadius,
            circleCenter.dx,
            circleRadius * 2,
          )
        : Rect.fromLTWH(
            circleCenter.dx,
            circleCenter.dy - circleRadius,
            size.width - circleCenter.dx,
            circleRadius * 2,
          );
    canvas.save();
    canvas.clipRect(clipRect);
    canvas.drawColor(Colors.black, BlendMode.srcOut); // Assuming black is the background color.
    canvas.restore();

    // Draw the triangles inside the circle.
    paint
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    _drawTriangle(canvas, Offset(circleCenter.dx - 4, circleCenter.dy), circleRadius, paint, isLeftSide: true);
    _drawTriangle(canvas, Offset(circleCenter.dx + 4, circleCenter.dy), circleRadius, paint, isLeftSide: false);
  }

  void _drawTriangle(Canvas canvas, Offset circleCenter, double radius, Paint paint, {required bool isLeftSide}) {
    Path path = Path();
    double sign = isLeftSide ? -1 : 1; // Determines the direction of the triangle.
    path.moveTo(circleCenter.dx + sign * radius / 2, circleCenter.dy);
    path.lineTo(circleCenter.dx, circleCenter.dy - radius / 2);
    path.lineTo(circleCenter.dx, circleCenter.dy + radius / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
