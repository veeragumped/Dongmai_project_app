import 'package:flutter/material.dart';

class Line extends StatelessWidget {

 final double top;
 final double left;
 final double width;

 const Line({super.key, 
    required this.top,
    required this.left,
    required this.width
  });


  @override
  Widget build(BuildContext context) {
    return Row(
            children: [
              Container(
                margin: EdgeInsets.only(top: top, left: left),
                height: 2,
                width: width,
                color: Color.fromARGB(255, 230, 230, 222),
              ),
            ],
          );
  }
}