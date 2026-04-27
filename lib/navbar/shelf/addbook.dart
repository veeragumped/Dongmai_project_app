import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/navbar/shelf/bookdetail.dart';
import 'package:gongdong/navbar/shelf/isbnscan.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/booksearchver.dart';
import 'package:gongdong/widgets/scrollablebook.dart';
import 'package:flutter_custom_icons/flutter_custom_icons.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  BookService bookService = BookService();
  List<BookModel> searchBooks = [];
  List<BookModel> trendingBooks = [];
  List<BookModel> topHitsBooks = [];
  List<BookModel> newBooks = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  void showSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      isLoading = true;
      isSearching = true;
    });
    var results = await bookService.fetchBooks(query);
    if (!mounted) return;
    setState(() {
      searchBooks = results;
      isLoading = false;
    });
  }

  void loadBooks() async {
    setState(() {
      isLoading = true;
    });

    var trending = await bookService.fetchBooks('ติดเทรนด์+หนังสือ');
    var hits = await bookService.fetchBooks('หนังสือยอดฮิต');
    var latest = await bookService.fetchBooks('นิยายแปล+ไทย+2026');

    if (!mounted) return;

    setState(() {
      trendingBooks = trending;
      topHitsBooks = hits;
      newBooks = latest;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Appcolors.jetblackColor,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Appcolors.creamywhiteColor),
            ),
            SizedBox(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Container(
                      height: 40,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Appcolors.creamywhiteColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'supermarket',
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: lp.translate('ค้นหา...', 'Search...'),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                        ),
                        onSubmitted: (value) {
                          showSearch(value);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final String? scannedIsbn = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Isbnscan();
                          },
                        ),
                      );
                      if (scannedIsbn != null && mounted) {
                        setState(() {
                          _searchController.text = scannedIsbn;
                          isLoading = true;
                        });
                      }
                      try {
                        final results = await bookService.fetchBooks(
                          'isbn:$scannedIsbn',
                        );
                        if (!mounted) return;
                        setState(() {
                          searchBooks = results;
                          isLoading = false;
                        });
                        if (results.isNotEmpty) {
                          final itemCount = results[0];
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Bookdetail(itemCount: itemCount),
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                lp.translate('ไม่พบข้อมูล', 'No data found'),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) return;
                        setState(() => isLoading = false);
                      }
                    },
                    icon: Icon(
                      FluentIcons.barcode,
                      size: 32,
                      color: Appcolors.lightgrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSearching)
                      Booksearchver(searchBooks: searchBooks)
                    else ...[
                      Scrollablebook(
                        text: lp.translate('กำลังมาแรง', 'Trending'),
                        itemCount: trendingBooks,
                        width: 100,
                        separatorwidth: 15,
                      ),
                      Scrollablebook(
                        text: lp.translate('ฮิตติดท็อป', 'Top Hits'),
                        itemCount: topHitsBooks,
                        width: 100,
                        separatorwidth: 15,
                      ),
                      Scrollablebook(
                        text: lp.translate('มาใหม่', 'New Arrivals'),
                        itemCount: newBooks,
                        width: 100,
                        separatorwidth: 15,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
