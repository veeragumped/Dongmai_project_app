import 'package:flutter/material.dart';
import 'package:gongdong/style/app_style.dart';

class Itemindeco extends StatelessWidget {
  final String imageurl;
  final double bottom;
  final VoidCallback onTap;
  final bool isOwned;
  final bool isSelected;
  final String category;

  const Itemindeco({
    super.key,
    required this.imageurl,
    required this.bottom,
    required this.onTap,
    required this.isOwned,
    required this.isSelected,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 0, right: 0, bottom: bottom),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: (isOwned && category != 'ชั้นหนังสือ') ? 0.6 : 1.0,
                    child: Image.asset(
                      imageurl,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: !isOwned
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.diamond, color: Appcolors.lightgrey),
                              Text(
                                '50',
                                style: TextStyle(
                                  color: Appcolors.lightgrey,
                                  fontFamily: 'print',
                                  fontSize: 30,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          )
                        : (category == 'ชั้นหนังสือ')
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          )
                        : Container(
                            margin: EdgeInsets.only(bottom: bottom),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ซื้อแล้ว',
                              style: TextStyle(
                                fontFamily: 'print',
                                fontSize: 25,
                                color: const Color.fromARGB(255, 15, 255, 23),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
