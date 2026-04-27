import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Booksscroll extends StatelessWidget {
  final String image;

  const Booksscroll({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Image.network(
        image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              height: 160,
              width: MediaQuery.of(context).size.width,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[600]!,
                child: Container(color: Colors.grey[800]),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: Icon(Icons.broken_image, color: Colors.white),
          );
        },
      ),
    );
  }
}
