import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/wishlist/wishlist.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Bookdetail extends StatelessWidget {
  final BookModel itemCount;

  const Bookdetail({super.key, required this.itemCount});

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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Image.network(itemCount.thumbnail, height: 300, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text(
              itemCount.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'supermarket',
              ),
            ),
            Text(
              'ผู้เขียน: ${itemCount.authors}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontFamily: 'supermarket',
              ),
            ),
            Text(
              lp.translate(
                'จำนวนหน้า: ${itemCount.pageCount} หน้า',
                'Page Count: ${itemCount.pageCount} pages',
              ),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontFamily: 'supermarket',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  lp.translate('คำอธิบาย:', 'Description:'),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'supermarket',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              itemCount.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'supermarket',
              ),
            ),
            const SizedBox(height: 30),
            LoginButton(
              text: lp.translate(
                'เพิ่มหนังสือลงชั้นหนังสือ',
                'Add to Bookshelf',
              ),
              height: 45,
              width: 305,
              color: Appcolors.copperColor,
              textcolor: Appcolors.creamywhiteColor,
              onPressed: () async {
                await BookService().addToShelf(itemCount);
                if (!context.mounted) return;

                // ใช้ lp ที่ประกาศไว้ข้างบนแทนการใช้ context.watch ในนี้
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                      lp.translate(
                        'เพิ่ม "${itemCount.title}" ลงชั้นหนังสือแล้ว!',
                        'Added "${itemCount.title}" to bookshelf!',
                      ),
                    ),
                  ),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 15),
            LoginButton(
              text: lp.translate('เพิ่มในรายการที่ต้องการ', 'Add to Wishlist'),
              height: 45,
              width: 305,
              color: Appcolors.copperColor,
              textcolor: Appcolors.creamywhiteColor,
              onPressed: () async {
                await BookService().addToWishlist(itemCount);
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lp.translate(
                        'เพิ่ม "${itemCount.title}" ใน wishlist แล้ว!',
                        'Added "${itemCount.title}" to wishlist!',
                      ),
                    ),
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Wishlist()),
                  (route) => route.isFirst,
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
