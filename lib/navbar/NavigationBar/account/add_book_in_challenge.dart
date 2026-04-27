import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/navbar/shelf/booksearchonshelf.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/shelf_bg.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class AddBookInChallenge extends StatefulWidget {
  const AddBookInChallenge({super.key});

  @override
  State<AddBookInChallenge> createState() => _AddBookInChallengeState();
}

class _AddBookInChallengeState extends State<AddBookInChallenge> {
  String currentShelfPath = 'assets/images/shelfbg.png';

  @override
  void initState() {
    super.initState();
    _loadShelfData();
  }

  void _loadShelfData() async {
    //final db = await DBHelper().db;
    String shelfImage = await BookService().getEquippedShelfImage();
    setState(() {
      currentShelfPath = shelfImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      appBar: AppBar(
        foregroundColor: Appcolors.creamywhiteColor,
        backgroundColor: Appcolors.jetblackColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              lp.translate('เลือกหนังสือ', 'Select Book'),
              style: TextStyle(fontFamily: 'supermarket', fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 76),
              child: IconButton(
                onPressed: () {
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Booksearchonshelf(),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.search_rounded),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Column(children: [ShelfBg(imagePaths: currentShelfPath)]),
                StreamBuilder<List<BookModel>>(
                  stream: BookService().getBooks(),
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
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(); // ไม่มีหนังสือก็ไม่ต้องโชว์อะไร
                    }
                    final books = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 40,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 50,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, book.thumbnail);
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
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
