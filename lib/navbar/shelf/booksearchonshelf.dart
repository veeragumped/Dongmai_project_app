import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/navbar/shelf/bookinfoonshelf.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Booksearchonshelf extends StatefulWidget {
  const Booksearchonshelf({super.key});

  @override
  State<Booksearchonshelf> createState() => _BooksearchonshelfState();
}

class _BooksearchonshelfState extends State<Booksearchonshelf> {
  final TextEditingController _searchController = TextEditingController();
  final bookService = BookService();
  String searchQuery = "";

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Appcolors.creamywhiteColor,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Appcolors.creamywhiteColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'supermarket',
                          fontSize: 20,
                        ),
                        controller: _searchController,
                        autofocus: true,
                        onChanged: onSearch,
                        decoration: InputDecoration(
                          hintText: lp.translate(
                            'ค้นหาหนังสือ...',
                            'Search Books...',
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Appcolors.lightgrey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Text(
                        lp.translate('พิมพ์เพื่อค้นหา', 'Type to search'),
                        style: TextStyle(
                          color: Appcolors.lightgrey,
                          fontFamily: 'supermarket',
                          fontSize: 30,
                        ),
                      ),
                    )
                  : StreamBuilder<List<BookModel>>(
                      stream: bookService.searchBooksInShelf(
                        _searchController.text,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              lp.translate(
                                'ไม่พบหนังสือที่ค้นหา',
                                'No books found',
                              ),
                              style: TextStyle(
                                color: Appcolors.lightgrey,
                                fontFamily: 'supermarket',
                                fontSize: 30,
                              ),
                            ),
                          );
                        }

                        final books = snapshot.data!;
                        return GridView.builder(
                          padding: EdgeInsets.all(20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 30,
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
                                        Bookinfoonshelf(itemCount: book),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  book.thumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
