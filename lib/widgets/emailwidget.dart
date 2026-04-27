import 'package:flutter/material.dart';
import 'package:gongdong/model/profile.dart';
import 'package:form_field_validator/form_field_validator.dart';

class Textwidget extends StatefulWidget {
  final String name;
  final double height;
  final double width;
  final Color color;
  final FormFieldSetter saved;
  final String errortext;

  const Textwidget({
    super.key,
    required this.name,
    required this.height,
    required this.width,
    required this.color,
    required this.saved,
    required this.errortext,
  });

  @override
  State<Textwidget> createState() => _TextwidgetState();
}

class _TextwidgetState extends State<Textwidget> {
  Profile profile = Profile();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextFormField(
        validator: RequiredValidator(errorText: widget.errortext).call,
        keyboardType: TextInputType.emailAddress,
        onSaved: widget.saved,
        decoration: InputDecoration(
          errorStyle: TextStyle(fontFamily: 'supermarket', fontSize: 22),
          hintText: widget.name,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: widget.color,
        ),
        style: TextStyle(fontFamily: 'supermarket', fontSize: 18),
      ),
    );
  }
}
