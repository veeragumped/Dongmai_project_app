import 'package:flutter/material.dart';

class Wishlistshelf extends StatelessWidget {
  const Wishlistshelf({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 180),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset('assets/images/wishlistshelf.png', width: 390),
        ),
      ],
    );
  }
}
