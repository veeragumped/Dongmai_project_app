import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/challengetypewidget.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Challengetype extends StatefulWidget {
  const Challengetype({super.key});

  @override
  State<Challengetype> createState() => _ChallengetypeState();
}

class _ChallengetypeState extends State<Challengetype> {
  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.jetblackColor,
        foregroundColor: Appcolors.creamywhiteColor,
      ),
      backgroundColor: Appcolors.jetblackColor,
      body: ListView(
        children: [
          Column(
            children: [
              Center(
                child: Text(
                  lp.translate(
                    'เลือก Challenge ที่ต้องการ',
                    'Select Challenge',
                  ),
                  style: TextStyle(
                    color: Appcolors.creamywhiteColor,
                    fontSize: 40,
                    fontFamily: 'print',
                  ),
                ),
              ),
              Challengetypewidget(
                title: 'Challenge',
                text: lp.translate('นี้', 'This Year'),
                onPressed: () {
                  final currentTitle = context
                      .read<LanguageProvider>()
                      .translate('ในปีนี้', 'In This Year');
                  showAlertyandm(context, currentTitle);
                },
              ),
              Challengetypewidget(
                title: 'Challenge',
                text: lp.translate('นี้', 'This Month'),
                onPressed: () {
                  final currentTitle = context
                      .read<LanguageProvider>()
                      .translate('ในเดือนนี้', 'In This Month');
                  showAlertyandm(context, currentTitle);
                },
              ),
              CreateChallengeWidget(
                onPressed: () {
                  final currentTitle = context
                      .read<LanguageProvider>()
                      .translate('สร้าง', 'Create');
                  showAlert(context, currentTitle);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showAlertyandm(BuildContext context, String title) {
    final TextEditingController controller = TextEditingController();
    final lp = context.read<LanguageProvider>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Appcolors.notelight,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lp.translate(
                    'ตั้งเป้าหมายว่าจะอ่านหนังสือกี่เล่ม ?',
                    'Set your goal for how many books you want to read?',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'print',
                    fontWeight: FontWeight.bold,
                    color: Appcolors.jetblackColor,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 1, left: 5),
                    hintText: lp.translate('จำนวนหนังสือ', 'Number of Books'),
                    filled: true,
                    fillColor: Color.fromRGBO(142, 142, 142, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    alertButton(
                      context,
                      lp.translate('ยกเลิก', 'Cancel'),
                      Appcolors.copperColor,
                      () => Navigator.pop(context),
                    ),
                    alertButton(
                      context,
                      lp.translate('ตกลง', 'Confirm'),
                      Appcolors.copperColor,
                      () async {
                        int goal = int.tryParse(controller.text) ?? 0;
                        if (goal > 0) {
                          await BookService().insertChallenge({
                            'title': lp.translate(
                              'อ่านหนังสือให้ได้ $goal เล่ม',
                              'Read $goal Books',
                            ),
                            'description': 'เป้าหมาย',
                            'goal_count': goal,
                            'current_count': 0,
                            'reward_points': 50,
                            'is_completed': 0,
                          });
                        }
                        if (context.mounted)
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAlert(BuildContext context, String title) {
    final TextEditingController controller = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final lp = context.read<LanguageProvider>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Appcolors.notelight,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lp.translate(
                    'ตั้งเป้าหมายว่าจะอ่านหนังสือกี่เล่ม ?',
                    'Set your goal for how many books you want to read?',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'print',
                    fontWeight: FontWeight.bold,
                    color: Appcolors.jetblackColor,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: lp.translate('ชื่อ ชาเลยจ์', 'Challenge Name'),
                    filled: true,
                    fillColor: Color.fromRGBO(142, 142, 142, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 19),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: lp.translate('จำนวนหนังสือ', 'Number of Books'),
                    filled: true,
                    fillColor: Color.fromRGBO(142, 142, 142, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    alertButton(
                      context,
                      lp.translate('ยกเลิก', 'Cancel'),
                      Appcolors.copperColor,
                      () => Navigator.pop(context),
                    ),
                    alertButton(
                      context,
                      lp.translate('ตกลง', 'Confirm'),
                      Appcolors.copperColor,
                      () async {
                        String t = titleController.text.trim();
                        int goal = int.tryParse(controller.text) ?? 0;
                        if (t.isNotEmpty && goal > 0) {
                          await BookService().insertChallenge({
                            'title': t,
                            'goal_count': goal,
                            'current_count': 0,
                          });
                          if (context.mounted)
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          if (mounted) setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget alertButton(
    BuildContext context,
    String title,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Appcolors.creamywhiteColor,
          fontSize: 26,
          fontFamily: 'print',
        ),
      ),
    );
  }
}
