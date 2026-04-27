import 'package:flutter/material.dart';
import 'package:gongdong/style/app_style.dart';

class Dropdown extends StatefulWidget {
  final List<String> items;
  final Widget label;
  final void Function(String?) onchanged;
  final Widget? child = Center();

  Dropdown({
    super.key,
    required this.items,
    required this.label,
    required this.onchanged,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? dropdownvalue;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 323,
          padding: EdgeInsets.only(left: 20, right: 10),
          decoration: BoxDecoration(
            color: Appcolors.lightgrey,
            border: Border.all(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              menuWidth: 323,
              padding: EdgeInsets.only(right: 20),
              items: widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dropdownvalue = value;
                });
                widget.onchanged(value);
              },
              hint: widget.label,
              value: dropdownvalue,
              style: TextStyle(
                fontFamily: 'supermarket',
                fontSize: 22,
                color: Appcolors.jetblackColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
