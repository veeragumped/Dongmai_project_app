import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class Passwordwidget extends StatefulWidget {

  final double height;
  final double width;
  final Color color;
  final FormFieldSetter saved;
  final String errortext;

  const Passwordwidget({super.key,
    required this.height,
    required this.width,
    required this.color,
    required this.saved,
    required this.errortext
  });

  @override
  State<Passwordwidget> createState() => _PasswordwidgetState();
}

class _PasswordwidgetState extends State<Passwordwidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
        child: TextFormField(
          validator: RequiredValidator(errorText: widget.errortext).call,
          onSaved: widget.saved,
          obscureText: true,
          decoration: InputDecoration(
            errorStyle: TextStyle(fontFamily: 'supermarket', fontSize: 22),
            hintText: 'รหัสผ่าน',
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            fillColor: widget.color,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none),
          ),style: TextStyle(fontFamily: 'supermarket',fontSize: 18),
        ),
      
    );
  }
}