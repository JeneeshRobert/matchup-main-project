import 'package:flutter/material.dart';

class LineAnimation extends StatefulWidget {
  @override
  _LineAnimationState createState() => _LineAnimationState();
}

class _LineAnimationState extends State<LineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1, _animation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation1 = Tween<double>(begin: 0, end: 200).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _animation2 = Tween<double>(begin: 0, end: 200).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Line Animation'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: LinePainter(_animation1.value, _animation2.value),
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double length1;
  final double length2;

  LinePainter(this.length1, this.length2);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    Offset start1 = Offset(10, 10);
    Offset end1_1 = Offset(10, length1 > 100 ? 100 : length1);
    Offset end1_2 = Offset(
        length1 > 100 ? length1 - 100 + 10 : 10, length1 > 100 ? 100 : length1);

    canvas.drawLine(start1, end1_1, paint);
    if (length1 > 100) {
      canvas.drawLine(end1_1, end1_2, paint);
    }

    Offset start2 = Offset(200, 10);
    Offset end2_1 = Offset(200, length2 > 100 ? 100 : length2);
    Offset end2_2 = Offset(length2 > 100 ? 200 - (length2 - 100) : 200,
        length2 > 100 ? 100 : length2);

    canvas.drawLine(start2, end2_1, paint);
    if (length2 > 100) {
      canvas.drawLine(end2_1, end2_2, paint);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.length1 != length1 || oldDelegate.length2 != length2;
  }
}
