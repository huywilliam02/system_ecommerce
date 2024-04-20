import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BNBCustomPainter extends CustomPainter {
  late final double bottomHeight = MediaQuery.of(Get.context!).viewPadding.bottom;
  @override
  void paint(Canvas canvas, Size size) {
    // double height = size.height + bottomHeight;
    Paint paint = Paint();
    Path path = Path();

    paint.color = Theme.of(Get.context!).primaryColor;
    path = Path()
    ..lineTo(size.width / 2, size.height * 0.65)
    ..cubicTo(size.width * 0.56, size.height * 0.65, size.width * 0.6, size.height * 0.45, size.width * 0.6, size.height * 0.19)
    ..cubicTo(size.width * 0.6, size.height * 0.16, size.width * 0.6, size.height * 0.13, size.width * 0.6, size.height * 0.1)
    ..cubicTo(size.width * 0.6, size.height * 0.05, size.width * 0.6, 0, size.width * 0.62, size.height * 0.01)
    ..cubicTo(size.width * 0.62, size.height * 0.01, size.width * 0.98, size.height / 5, size.width * 0.98, size.height / 5)
    ..cubicTo(size.width, size.height / 5, size.width, size.height * 0.27, size.width, size.height / 3)
    ..cubicTo(size.width, size.height / 3, size.width, size.height * 0.94, size.width, size.height * 0.94)
    ..cubicTo(size.width, size.height * 0.98, size.width, size.height, size.width, size.height)
    ..cubicTo(size.width, size.height, size.width * 0.01, size.height, size.width * 0.01, size.height)
    ..cubicTo(size.width * 0.01, size.height, 0, size.height, 0, size.height)
    ..cubicTo(0, size.height * 0.94, 0, size.height / 3, 0, size.height / 3)
    ..cubicTo(0, size.height * 0.27, size.width * 0.01, size.height / 5, size.width * 0.02, size.height / 5)
    ..cubicTo(size.width * 0.02, size.height / 5, size.width * 0.4, 0, size.width * 0.387, 0)
    ..cubicTo(size.width * 0.4, 0, size.width * 0.4, size.height * 0.05, size.width * 0.4, size.height * 0.1)
    ..cubicTo(size.width * 0.4, size.height * 0.13, size.width * 0.4, size.height * 0.16, size.width * 0.4, size.height * 0.19)
    ..cubicTo(size.width * 0.4, size.height * 0.45, size.width * 0.45, size.height * 0.65, size.width / 2, size.height * 0.65)
    ..cubicTo(size.width / 2, size.height * 0.65, size.width / 2, size.height * 0.65, size.width / 2, size.height * 0.65);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// class BNBCustomPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Theme.of(Get.context!).primaryColor
//       ..style = PaintingStyle.fill;
//
//     Path path = Path();
//     path.moveTo(0, 20); // Start
//     path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
//     path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
//     path.arcToPoint(Offset(size.width * 0.60, 20), radius: const Radius.circular(20.0), clockwise: false);
//     path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
//     path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.lineTo(0, 20);
//     canvas.drawShadow(path, Colors.black, 5, true);
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
