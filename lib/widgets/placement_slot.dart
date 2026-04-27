import 'package:flutter/material.dart';

class PlacementSlot extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final VoidCallback onTap;

  const PlacementSlot({
    super.key,
    required this.top,
    this.left,
    this.right,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
