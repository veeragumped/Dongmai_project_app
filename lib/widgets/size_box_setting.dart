import 'package:flutter/material.dart';
import 'package:gongdong/style/app_style.dart';

class SizeBoxSetting extends StatelessWidget {
  final String text;
  final double fontsize;
  final String textUnder;
  final Color boxcolor;
  final Color textcolor;

  const SizeBoxSetting({
    super.key,
    required this.text,
    required this.fontsize,
    required this.textUnder,
    this.boxcolor = Colors.white,
    this.textcolor = Colors.black,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 67,
          decoration: BoxDecoration(
            color: boxcolor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textcolor,
                fontSize: fontsize,
                fontFamily: 'print',
              ),
            ),
          ),
        ),
        Text(
          textUnder,
          style: TextStyle(
            color: Appcolors.creamywhiteColor,
            fontSize: 30,
            fontFamily: 'print',
          ),
        ),
      ],
    );
  }
}
