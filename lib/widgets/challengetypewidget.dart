import 'package:flutter/material.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Challengetypewidget extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback onPressed;

  const Challengetypewidget({
    super.key,
    required this.text,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 34, top: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/challange_logo.png', scale: 1.9),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Appcolors.creamywhiteColor,
                      fontFamily: 'print',
                      fontSize: 35,
                      height: 1,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Appcolors.creamywhiteColor,
                        fontSize: 20,
                        fontFamily: 'print',
                      ),
                      children: [
                        TextSpan(text: lp.translate('ใน ', '')),
                        TextSpan(
                          text: text,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: lp.translate(
                            ' นี้ คุณจะอ่านหนังสือกี่เล่ม ?',
                            ' how many books u\'ll read?',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        LoginButton(
          text: lp.translate('เลือกชาร์เลนจ์นี้', 'Select This Challenge'),
          height: 42,
          width: 342,
          color: Appcolors.copperColor,
          textcolor: Appcolors.creamywhiteColor,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class CreateChallengeWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const CreateChallengeWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 34, top: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/challange_logo.png', scale: 1.9),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lp.translate('ชาเลนจ์', 'Challenge'),
                    style: const TextStyle(
                      color: Appcolors.creamywhiteColor,
                      fontFamily: 'print',
                      fontSize: 35,
                      height: 1,
                    ),
                  ),
                  Text(
                    lp.translate(
                      'สร้างสรรค์ชาร์เลนจ์ของตัวเอง !',
                      'Create Your Own Challenge !',
                    ),
                    style: const TextStyle(
                      fontFamily: 'print',
                      fontSize: 20,
                      color: Appcolors.creamywhiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        LoginButton(
          text: lp.translate('เลือกชาร์เลนจ์นี้', 'Select This Challenge'),
          height: 42,
          width: 342,
          color: Appcolors.copperColor,
          textcolor: Appcolors.creamywhiteColor,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
