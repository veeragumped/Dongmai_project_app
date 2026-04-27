import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 275,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 230, 230, 222),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                image,
                height: 145.14,
                width: 180,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxLines: 2,
                    title,
                    style: TextStyle(
                      fontFamily: 'print',
                      fontSize: 14,
                      color: Color.fromARGB(255, 51, 50, 55),
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    description,
                    style: TextStyle(
                      fontFamily: 'supermarket',
                      fontSize: 12,
                      color: Color.fromARGB(255, 51, 50, 55),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
