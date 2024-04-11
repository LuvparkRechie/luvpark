import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class CustomTicketWidget extends StatefulWidget {
  final Widget myWidget;
  final String zoneName;
  final double ticketHeight;
  const CustomTicketWidget(
      {super.key,
      required this.myWidget,
      required this.zoneName,
      required this.ticketHeight});

  @override
  State<CustomTicketWidget> createState() => _CustomTicketWidgetState();
}

class _CustomTicketWidgetState extends State<CustomTicketWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.ticketHeight,
      child: Stack(children: [
        Row(
          children: [
            Expanded(
              child: Container(
                color: AppColor.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: RotatedBox(
                    quarterTurns: 3,
                    child: CustomDisplayText(
                      label: widget.zoneName,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      alignment: TextAlign.center,
                      color: Colors.white,
                    ),
                  )),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: widget.myWidget,
            ),
          ],
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: SideCutsDesign(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: DottedInitialPath(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: DottedMiddlePath(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
            ),
          ),
        ),
      ]),
    );
  }
}

class DottedMiddlePath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3;
    double dashSpace = 4;
    double startY = 10;
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    while (startY < size.height - 10) {
      canvas.drawCircle(Offset(size.width / 5, startY), 2, paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DottedInitialPath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3;
    double dashSpace = 4;
    double startY = 10;
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    while (startY < size.height - 10) {
      canvas.drawCircle(Offset(0, startY), 2, paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SideCutsDesign extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var h = size.height;
    var w = size.width;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, h / 2), radius: 18),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w, h / 2), radius: 18),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w / 5, h), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w / 5, 0), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, h), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: const Offset(0, 0), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
