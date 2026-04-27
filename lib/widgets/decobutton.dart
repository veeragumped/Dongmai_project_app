import 'package:flutter/material.dart';

class Decobutton extends StatelessWidget {
  final String text;
  final double left;
  final double right;
  final double top;
  final double bottom;
  final Color boxcolor;
  final Color textcolor;

  const Decobutton({
    super.key,
    required this.text,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.boxcolor,
    required this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        padding: EdgeInsets.only(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: boxcolor,
          border: Border.all(width: 2),
        ),
        child: Text(
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(color: textcolor, fontSize: 26, fontFamily: 'print'),
        ),
      ),
    );
  }
}
