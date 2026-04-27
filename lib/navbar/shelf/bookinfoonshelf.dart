import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/navbar/NavigationBar/note/notereal.dart';
//import 'package:gongdong/navbar/shelf/bookdetail.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:flutter_custom_icons/flutter_custom_icons.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Bookinfoonshelf extends StatefulWidget {
  final BookModel itemCount;

  const Bookinfoonshelf({super.key, required this.itemCount});

  @override
  State<Bookinfoonshelf> createState() => _BookinfoonshelfState();
}

class _BookinfoonshelfState extends State<Bookinfoonshelf> {
  late String seletedStatus;
  @override
  void initState() {
    super.initState();
    seletedStatus = widget.itemCount.status;
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      appBar: AppBar(
        backgroundColor: Appcolors.jetblackColor,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(
                  widget.itemCount.thumbnail,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: -5,
                  right: -30,
                  child: IconButton(
                    icon: Icon(
                      widget.itemCount.isFavorite == 1
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.itemCount.isFavorite == 1
                          ? Appcolors.copperColor
                          : Appcolors.lightgrey,
                      size: 70,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                    onPressed: () async {
                      await BookService().favorite(
                        widget.itemCount.id,
                        widget.itemCount.isFavorite,
                      );
                      setState(() {
                        widget.itemCount.isFavorite =
                            (widget.itemCount.isFavorite == 1) ? 0 : 1;
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.itemCount.isFavorite == 1
                                ? lp.translate(
                                    'เพิ่ม "${widget.itemCount.title}" ในรายการโปรดแล้ว',
                                    'Added "${widget.itemCount.title}" to favorites!',
                                  )
                                : lp.translate(
                                    'นำออกจากรายการโปรดแล้ว',
                                    'Removed "${widget.itemCount.title}" from favorites!',
                                  ),
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 65,
                    height: 65,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Appcolors.copperColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Notereal(itemCount: widget.itemCount);
                            },
                          ),
                        );
                      },
                      icon: Icon(
                        Iconixto.note,
                        size: 40,
                        color: Appcolors.lightgrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Text(
              widget.itemCount.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'supermarket',
              ),
            ),
            Text(
              'ผู้เขียน: ${widget.itemCount.authors}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontFamily: 'supermarket',
              ),
            ),
            Text(
              lp.translate(
                'จำนวนหน้า: ${widget.itemCount.pageCount} หน้า',
                'Page Count: ${widget.itemCount.pageCount} pages',
              ),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontFamily: 'supermarket',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  context.watch<LanguageProvider>().translate(
                    'คำอธิบาย:',
                    'Description:',
                  ),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'supermarket',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              widget.itemCount.description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'supermarket',
              ),
            ),
            SizedBox(height: 30),
            LoginButton(
              text: lp.translate('ลบหนังสือ', 'Delete Book'),
              height: 45,
              width: 305,
              color: Appcolors.copperColor,
              textcolor: Appcolors.creamywhiteColor,
              onPressed: () async {
                if (widget.itemCount.id.isNotEmpty) {
                  await BookService().deleteBook(widget.itemCount.id);
                  if (context.mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lp.translate(
                          'ไม่สามารถลบหนังสือได้',
                          'Failed to delete book',
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 15),
            Container(
              width: 305,
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Appcolors.copperColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: Offset(0, 4),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: seletedStatus,
                  isExpanded: true,
                  dropdownColor: Appcolors.copperColor,
                  style: TextStyle(
                    fontFamily: 'supermarket',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'ยังไม่ได้อ่าน',
                      child: Center(
                        child: Text(lp.translate('ยังไม่ได้อ่าน', 'Not Read')),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'กำลังอ่าน',
                      child: Center(
                        child: Text(lp.translate('กำลังอ่าน', 'Reading')),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'อ่านจบแล้ว',
                      child: Center(
                        child: Text(
                          lp.translate('อ่านจบแล้ว', 'Finished Reading'),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      setState(() {
                        seletedStatus = newValue;
                      });
                      await BookService().updateBookStatus(
                        widget.itemCount.id,
                        newValue,
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
