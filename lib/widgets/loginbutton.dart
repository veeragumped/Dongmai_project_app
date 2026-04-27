import 'package:flutter/material.dart';

class LoginButton extends StatefulWidget {
  final String text;
  final double height;
  final double width;
  final Color color;
  final Color textcolor;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.text,
    required this.height,
    required this.width,
    required this.color,
    required this.textcolor,
    required this.onPressed,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: Offset(0, 4),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.textcolor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'supermarket',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
