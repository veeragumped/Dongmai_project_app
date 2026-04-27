import 'package:flutter/material.dart';

class Category extends StatelessWidget {

  const Category({super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Container(
                height: 80,
                width: 368,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 163, 134, 85),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        )]);
}}
