import 'package:flutter/material.dart';
import 'package:gongdong/navbar/shelf/addbook.dart';
import 'package:gongdong/model/book_model.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/wishlist/wishlistinfo.dart';
import 'package:gongdong/wishlist/wishlistshelf.dart';
import 'package:gongdong/model/book_service.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Appcolors.creamywhiteColor),
        backgroundColor: Appcolors.jetblackColor,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Icon(
                Icons.star,
                color: Appcolors.creamywhiteColor,
                size: 32,
              ),
            ),
            Text(
              'Wishlist',
              style: TextStyle(
                color: Appcolors.creamywhiteColor,
                fontFamily: 'supermarket',
                fontSize: 30,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.edit, color: Appcolors.creamywhiteColor),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddBook();
                    },
                  ),
                );
              },
              icon: Icon(Icons.add, color: Appcolors.creamywhiteColor),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(color: Color.fromARGB(255, 230, 230, 222), thickness: 2),
            StreamBuilder<List<BookModel>>(
              stream: BookService().getWishlistBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Appcolors.copperColor,
                      ),
                    ),
                  );
                }
                final books = snapshot.data ?? [];
                int shelfNeeded = (books.length / 12).ceil();
                if (shelfNeeded == 0) shelfNeeded = 1;
                return Stack(
                  children: [
                    Column(
                      children: [
                        for (int i = 0; i < shelfNeeded; i++) Wishlistshelf(),
                      ],
                    ),
                    if (books.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: 20, right: 20, top: 40),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 50,
                          mainAxisSpacing: 60,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Wishlistinfo(itemCount: book),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  book.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey,
                                        child: Icon(Icons.broken_image),
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
