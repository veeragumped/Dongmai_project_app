import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/model/db.dart';
import 'package:gongdong/navbar/NavigationBar/account/edit_challege.dart';

class Challengewidget extends StatefulWidget {
  final VoidCallback onRefresh;
  final String id;
  final String title;
  final int currentCount;
  final int goalCount;

  const Challengewidget({
    super.key,
    required this.id,
    required this.title,
    required this.currentCount,
    required this.goalCount,
    required this.onRefresh,
  });

  @override
  State<Challengewidget> createState() => _ChallengewidgetState();
}

class _ChallengewidgetState extends State<Challengewidget> {
  late int displayCount;
  late String displayTitle;
  late int displayGoal;
  List<String> currentImages = [];

  Future<List<Map<String, dynamic>>>? challageFuture;

  void refreshAccount() {
    setState(() {
      challageFuture = DBHelper().getChallenge();
    });
  }

  @override
  void initState() {
    super.initState();
    displayCount = widget.currentCount;
    displayGoal = widget.goalCount;
    displayTitle = widget.title;
    loadSaveBooks();
    refreshAccount();
  }

  @override
  Widget build(BuildContext context) {
    double progress = displayGoal > 0 ? displayCount / displayGoal : 0.0;
    int percentage = (progress * 100).toInt();

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        width: 368,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 163, 134, 85),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'print',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '$displayCount/$displayGoal',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EditChallege(
                              id: widget.id,
                              currentTitle: widget.title,
                              currentCount: displayCount,
                              goalCount: displayGoal,
                              images: currentImages,
                            );
                          },
                        ),
                      );
                      refreshAccount();
                      if (!context.mounted) return;
                      if (result == 'deleted') {
                        widget.onRefresh();
                      } else if (result != null && result is Map) {
                        setState(() {
                          displayTitle = result['title'];
                          displayGoal = result['goal'];
                          displayCount = result['count'];
                          currentImages = List<String>.from(result['books']);
                        });
                      }
                    },
                    child: Icon(
                      Icons.mode_edit_outline_outlined,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  Color.fromRGBO(229, 104, 86, 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loadSaveBooks() async {
    final List<String> savedData = await BookService()
        .getChallengeBooks(widget.id)
        .first;
    setState(() {
      currentImages = savedData;
    });
  }
}
