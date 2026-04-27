import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

//final dbHelper = DBHelper();

class Wishlistinfo extends StatefulWidget {
  final BookModel itemCount;

  const Wishlistinfo({super.key, required this.itemCount});

  @override
  State<Wishlistinfo> createState() => _WishlistinfoState();
}

class _WishlistinfoState extends State<Wishlistinfo> {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.itemCount.thumbnail,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              lp.translate(
                'ผู้เขียน: ${widget.itemCount.authors}',
                'Authors: ${widget.itemCount.authors}',
              ),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontFamily: 'supermarket',
              ),
            ),
            Text(
              widget.itemCount.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'supermarket',
              ),
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
            SizedBox(height: 15),
            LoginButton(
              text: lp.translate('ซื้อหนังสือเล่มนี้แล้ว', 'Already bought'),
              height: 45,
              width: 305,
              color: Appcolors.copperColor,
              textcolor: Appcolors.creamywhiteColor,
              onPressed: () async {
                await BookService().moveToShelf(widget.itemCount);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lp.translate(
                        'ย้าย ${widget.itemCount.title} ไปที่ชั้นหนังสือแล้ว!',
                        '${widget.itemCount.title} has been moved to the bookshelf!',
                      ),
                    ),
                    backgroundColor: Appcolors.jetblackColor,
                  ),
                );
                Navigator.pop(context);
              },
            ),
            LoginButton(
              text: lp.translate(
                'ลบหนังสือออกจาก Wishlist',
                'Remove the book from your Wishlist.',
              ),
              height: 45,
              width: 305,
              color: Appcolors.copperColor,
              textcolor: Appcolors.creamywhiteColor,
              onPressed: () async {
                await BookService().deleteWishlistBook(widget.itemCount.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lp.translate(
                        'ลบ "${widget.itemCount.title}" ออกจากชั้นหนังสือแล้ว!',
                        '${widget.itemCount.title}" has been removed from the bookshelf!',
                      ),
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
