import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/navbar/NavigationBar/account/add_book_in_challenge.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class EditChallege extends StatefulWidget {
  final String id;
  final String currentTitle;
  final int goalCount;
  final int currentCount;
  final List<String> images;

  const EditChallege({
    super.key,
    required this.id,
    required this.currentTitle,
    required this.goalCount,
    required this.currentCount,
    required this.images,
  });

  @override
  State<EditChallege> createState() => _EditChallegeState();
}

class _EditChallegeState extends State<EditChallege> {
  List<String> finishedBooks = [];
  late String displayTitle;
  late int displayGoal;
  final ScrollController scrollController = ScrollController();
  final GlobalKey<RawScrollbarState> scrollbarKey =
      GlobalKey<RawScrollbarState>();

  @override
  void initState() {
    super.initState();
    finishedBooks = List<String>.from(widget.images);
    displayTitle = widget.currentTitle;
    displayGoal = widget.goalCount;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    int totalRead = finishedBooks.length;
    double progress = (displayGoal > 0)
        ? (totalRead / displayGoal).clamp(0.0, 1.0)
        : 0.0;
    int percentage = (displayGoal > 0) ? (progress * 100).toInt() : 0;
    if (percentage > 100) percentage = 100;

    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(left: 340),
              child: IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.red.shade400,
                  size: 30,
                ),
                onPressed: () {
                  showDeleteDialog(context);
                },
              ),
            ),
            Column(
              children: [
                Container(
                  height: 550,
                  width: 370,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Appcolors.copperColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  displayTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'print',
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.mode_edit_outline_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showAlert(context, displayTitle);
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                '$totalRead/$displayGoal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'print',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            SizedBox(height: 10),
                            Expanded(
                              child: ClipRRect(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 5,
                                  backgroundColor: Appcolors.lightgrey,
                                  valueColor: AlwaysStoppedAnimation(
                                    Color.from(
                                      alpha: 1,
                                      red: 0.898,
                                      green: 0.408,
                                      blue: 0.337,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'print',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              lp.translate(
                                'หนังสือที่อ่านจบแล้ว',
                                'Books You Have Read',
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'print',
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Scrollbar(
                          key: scrollbarKey,
                          controller: scrollController,
                          thumbVisibility: true,
                          thickness: 6,
                          radius: Radius.circular(10),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            primary: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ...finishedBooks.map(
                                  (imageUrl) => Stack(
                                    children: [
                                      Container(
                                        width: 85,
                                        height: 125,
                                        margin: EdgeInsets.only(
                                          bottom: 5,
                                          top: 8,
                                          right: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 4,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        left: 70,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              finishedBooks.remove(imageUrl);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (finishedBooks.length >= displayGoal) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            lp.translate(
                                              'คุณทำชาเลนจ์ครบตามเป้าหมายแล้ว!',
                                              'You have completed the challenge!',
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'print',
                                              fontSize: 30,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor:
                                              Appcolors.copperColor,
                                        ),
                                      );
                                      return;
                                    }
                                    final String? image = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddBookInChallenge();
                                        },
                                      ),
                                    );
                                    if (image != null) {
                                      if (finishedBooks.contains(image)) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 2),
                                              content: Text(
                                                context
                                                    .watch<LanguageProvider>()
                                                    .translate(
                                                      'หนังสือเล่มนี้ถูกเพิ่มไปแล้ว กรุณาเลือกเล่มอื่น',
                                                      'This book has already been added. Please select another book.',
                                                    ),
                                                style: TextStyle(
                                                  fontFamily: 'print',
                                                  color: Appcolors
                                                      .creamywhiteColor,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        setState(() {
                                          finishedBooks.add(image);
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 85,
                                    height: 125,
                                    decoration: BoxDecoration(
                                      color: finishedBooks.length >= displayGoal
                                          ? Colors.white.withValues(alpha: 0.0)
                                          : Colors.white.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: finishedBooks.length >= displayGoal
                                          ? Colors.white.withValues(alpha: 0.0)
                                          : Appcolors.copperColor,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginButton(
                      text: lp.translate('ยกเลิก', 'Cancel'),
                      height: 40,
                      width: 60,
                      color: Appcolors.copperColor,
                      textcolor: Appcolors.creamywhiteColor,
                      onPressed: () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    LoginButton(
                      text: lp.translate('ตกลง', 'Confirm'),
                      height: 40,
                      width: 60,
                      color: Appcolors.copperColor,
                      textcolor: Appcolors.creamywhiteColor,
                      onPressed: () async {
                        int currentCount = finishedBooks.length;
                        await BookService().updateChallengeProgress(
                          widget.id,
                          displayTitle,
                          displayGoal,
                          currentCount,
                        );
                        await BookService().saveChallengeProgress(
                          widget.id,
                          finishedBooks,
                        );
                        if (currentCount >= displayGoal) {
                          await BookService().claimChallengeReward(
                            widget.id,
                            displayGoal,
                          );
                          if (context.mounted) {
                            int totalEarned = displayGoal * 10;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  lp.translate(
                                    'ภารกิจสำเร็จ ได้รับ $totalEarned เพชร!',
                                    'Challenge completed! You earned $totalEarned gems!',
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'print',
                                    color: Colors.black,
                                    fontSize: 30,
                                  ),
                                ),
                                backgroundColor: Appcolors.creamywhiteColor,
                              ),
                            );
                            Navigator.pop(context, 'deleted');
                          }
                        } else {
                          if (context.mounted) {
                            Navigator.pop(context, {
                              'title': displayTitle,
                              'goal': displayGoal,
                              'count': currentCount,
                              'books': finishedBooks,
                            });
                          }
                          if (mounted) setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          context.watch<LanguageProvider>().translate(
            'ลบภารกิจนี้ ?',
            'Delete this challenge?',
          ),
          style: TextStyle(fontFamily: 'print'),
        ),
        content: Text(
          context.watch<LanguageProvider>().translate(
            'คุณแน่ใจใช่ไหมที่จะลบภารกิจนี้ ?',
            'Are you sure you want to delete this challenge?',
          ),
          style: TextStyle(fontFamily: 'print', fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              context.watch<LanguageProvider>().translate('ยกเลิก', 'Cancel'),
              style: TextStyle(
                fontFamily: 'print',
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await BookService().deleteChallenge(widget.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context, 'deleted');
              }
            },
            child: Text(
              context.watch<LanguageProvider>().translate('ลบเลย', 'Delete'),
              style: TextStyle(
                fontFamily: 'print',
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAlert(BuildContext context, String title) {
    final TextEditingController controller = TextEditingController();
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  context.watch<LanguageProvider>().translate(
                    'แก้ไขเป้าหมายการอ่าน ?',
                    'Edit Reading Goal?',
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
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 1, left: 5),
                    hintText: context.watch<LanguageProvider>().translate(
                      'ชื่อ Challenge',
                      'Challenge Name',
                    ),
                    hintStyle: TextStyle(
                      fontFamily: 'print',
                      fontSize: 24,
                      color: Color.fromRGBO(95, 95, 95, 255),
                    ),
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
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 1, left: 5),
                    hintText: context.watch<LanguageProvider>().translate(
                      'จำนวนหนังสือ',
                      'Number of Books',
                    ),
                    hintStyle: TextStyle(
                      fontFamily: 'print',
                      fontSize: 24,
                      color: Color.fromRGBO(95, 95, 95, 255),
                    ),
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
                      context.watch<LanguageProvider>().translate(
                        'ยกเลิก',
                        'Cancel',
                      ),
                      Appcolors.copperColor,
                      () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    alertButton(
                      context,
                      context.watch<LanguageProvider>().translate(
                        'ตกลง',
                        'Confirm',
                      ),
                      Appcolors.copperColor,
                      () async {
                        String title = titleController.text.trim();
                        String goalText = controller.text;
                        int goal = int.tryParse(goalText) ?? 0;
                        if (title.isNotEmpty && goal > 0) {
                          await BookService().updateChallengeProgress(
                            widget.id,
                            displayTitle,
                            displayGoal,
                            goal,
                          );
                          if (mounted) {
                            setState(() {
                              displayTitle = title;
                              displayGoal = goal;
                            });
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.watch<LanguageProvider>().translate(
                                  'กรุณากรอกชื่อและจำนวน',
                                  'Please fill in the name and number',
                                ),
                              ),
                            ),
                          );
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
