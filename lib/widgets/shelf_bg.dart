import 'package:flutter/material.dart';

class ShelfBg extends StatelessWidget {
  final String imagePaths;

  const ShelfBg({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 790,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePaths),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
