import 'package:flutter/material.dart';

class Registerwidget extends StatelessWidget {
  const Registerwidget({super.key});


  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return TextButton(
      onPressed: () {
        formKey.currentState!.save();
      },
      child: Container(
        height: 38,
        width: 350,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 163, 134, 85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'สร้างบัญชี',
              style: TextStyle(
                color: Color.fromARGB(255, 240, 235, 216),
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
