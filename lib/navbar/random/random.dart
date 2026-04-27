import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:gongdong/navbar/shelf/bookdetail.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/dropdown.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/widgets/scrollablebook.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Random extends StatefulWidget {
  const Random({super.key});

  @override
  State<Random> createState() => _RandomState();
}

class _RandomState extends State<Random> {
  bool isSpinning = false;
  bool isLoading = true;
  bool isReadyToScroll = false;
  String? selectedDropdown;
  final ScrollController mainScrollController = ScrollController();

  BookService bookService = BookService();
  BookModel? winnerBook;
  List<BookModel> showbooks = [];
  List<BookModel> bookshelf = [];
  List<BookModel> author = [];
  List<BookModel> booksgenre = [];
  List<BookModel> publisher = [];
  List<BookModel> currentDisplayList = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  @override
  void dispose() {
    mainScrollController.dispose();
    super.dispose();
  }

  void loadBooks() async {
    setState(() {
      isLoading = true;
      isReadyToScroll = false;
    });

    try {
      final localData = await bookService.getBooksFromShelf().first;

      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;
      setState(() {
        currentDisplayList = localData;
        isLoading = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => isReadyToScroll = true);
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
    try {
      showbooks = await bookService.fetchBooks('นิยาย');
      author = await bookService.fetchBooks('inauthor:');
      booksgenre = await bookService.fetchBooks('subject:');
      publisher = await bookService.fetchBooks('inpublisher:');
    } catch (e) {
      debugPrint('API ERROR: $e');
    }
  }

  void pickWinner() {
    setState(() {
      if (currentDisplayList.isNotEmpty) {
        var randomList = List<BookModel>.from(currentDisplayList);
        randomList.shuffle();
        winnerBook = randomList.first;
        isSpinning = false;
      }
    });
  }

  Widget _buildBookShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF3D2B1F),
      highlightColor: const Color(0xFF5A4638),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 115,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRandoming() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Text(
                    context.watch<LanguageProvider>().translate(
                      'สุ่มหนังสือing',
                      'Randoming!',
                    ),
                    style: TextStyle(
                      fontFamily: 'supermarket',
                      fontSize: 42,
                      color: Appcolors.creamywhiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              (isLoading)
                  ? Center(child: _buildBookShimmer())
                  : (currentDisplayList.isEmpty)
                  ? Center(
                      child: Text(
                        context.watch<LanguageProvider>().translate(
                          'ไม่มีหนังสือในชั้นหนังสือ',
                          'No books in the bookshelf',
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SizedBox(
                      height: 250,
                      child: ScrollLoopAutoScroll(
                        key: ValueKey(
                          '${selectedDropdown}_${currentDisplayList.length}',
                        ),
                        scrollDirection: Axis.horizontal,
                        delay: const Duration(seconds: 1),
                        duration: const Duration(seconds: 5),
                        gap: 1,
                        enableScrollInput: false,
                        child: Row(
                          children: [
                            Scrollablebook.noscroll(
                              text: '',
                              itemCount: currentDisplayList,
                              width: 115,
                              separatorwidth: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginButton(
                    text: context.watch<LanguageProvider>().translate(
                      'หยุด!',
                      'Stop',
                    ),
                    height: 50,
                    width: 100,
                    color: Appcolors.lightgrey,
                    textcolor: Appcolors.jetblackColor,
                    onPressed: () {
                      pickWinner();
                      if (winnerBook != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Bookdetail(itemCount: winnerBook!),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showAlert(BuildContext context, String title) async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.watch<LanguageProvider>().translate(
            'ค้นหาตาม$title',
            'Search by $title',
          ),
          style: const TextStyle(fontFamily: 'supermarket'),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.watch<LanguageProvider>().translate(
              'พิมพ์ชื่อ $title ที่ต้องการ',
              'Enter the $title you want to search for',
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.watch<LanguageProvider>().translate('ยกเลิก', 'Cancel'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              context.watch<LanguageProvider>().translate('ตกลง', 'OK'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updatedDropdown(String? category) async {
    final lp = context.read<LanguageProvider>();
    if (category == lp.translate('ชั้นหนังสือ', 'Bookshelf')) {
      setState(() {
        isLoading = true;
        isReadyToScroll = false;
      });
      try {
        var localBooks = await bookService.getBooksFromShelf().first;
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        setState(() {
          currentDisplayList = localBooks;
          selectedDropdown = category;
          isLoading = false;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => isReadyToScroll = true);
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else if (category != null) {
      String? userInput = await _showAlert(context, category);
      if (userInput != null && userInput.isNotEmpty) {
        setState(() {
          isLoading = true;
          isReadyToScroll = false;
        });

        String query = '';
        if (category == lp.translate('ผู้เขียน', 'Author')) {
          query = 'inauthor:$userInput';
        } else if (category == lp.translate('ประเภทหนังสือ', 'Book Type')) {
          query = 'subject:$userInput';
        } else if (category == lp.translate('สำนักพิมพ์', 'Publisher')) {
          query = 'inpublisher:$userInput';
        }
        try {
          var searchResults = await bookService.fetchBooks(query);
          if (!mounted) return;

          if (searchResults.isEmpty) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lp.translate(
                    'ไม่พบหนังสือสำหรับ "$userInput"',
                    'No books found for "$userInput"',
                  ),
                  style: const TextStyle(fontFamily: 'supermarket'),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else {
            setState(() {
              selectedDropdown = category;
              currentDisplayList = searchResults;
              isLoading = false;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => isReadyToScroll = true);
            });
          }
        } catch (e) {
          if (mounted) setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      body: ListView(
        controller: mainScrollController,
        primary: false,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 110),
            child: Center(
              child: Text(
                lp.translate('สุ่มหนังสือเล่มต่อไปกัน!', 'Randoming!'),
                style: TextStyle(
                  fontFamily: 'supermarket',
                  fontSize: 42,
                  color: Appcolors.creamywhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Dropdown(
            items: [
              lp.translate('ชั้นหนังสือ', 'Bookshelf'),
              lp.translate('ผู้เขียน', 'Author'),
              lp.translate('ประเภทหนังสือ', 'Book Type'),
              lp.translate('สำนักพิมพ์', 'Publisher'),
            ],
            label: Center(
              child: Text(
                lp.translate('เลือกประเภทของหนังสือ', 'Select Book Category'),
                style: TextStyle(
                  fontFamily: 'supermarket',
                  fontSize: 22,
                  color: Appcolors.jetblackColor,
                ),
              ),
            ),
            onchanged: updatedDropdown,
          ),
          const SizedBox(height: 50),
          (isLoading)
              ? _buildBookShimmer()
              : (currentDisplayList.isEmpty || !isReadyToScroll)
              ? const SizedBox(height: 170)
              : ScrollLoopAutoScroll(
                  key: ValueKey(
                    '${selectedDropdown}_${currentDisplayList.length}',
                  ),
                  scrollDirection: Axis.horizontal,
                  delay: const Duration(seconds: 1),
                  duration: const Duration(seconds: 80),
                  gap: 1,
                  enableScrollInput: false,
                  child: Scrollablebook.noscroll(
                    text: '',
                    itemCount: currentDisplayList,
                    width: 115,
                    separatorwidth: 5,
                  ),
                ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginButton(
                text: lp.translate('เริ่ม', 'Start'),
                height: 50,
                width: 100,
                color: Appcolors.lightgrey,
                textcolor: Appcolors.jetblackColor,
                onPressed: currentDisplayList.isEmpty
                    ? () {}
                    : () {
                        showGeneralDialog(
                          barrierColor: Colors.black.withValues(alpha: 0.5),
                          barrierDismissible: true,
                          barrierLabel: lp.translate('เริ่ม', 'Start'),
                          context: context,
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, anim1, anim2) =>
                              _buildRandoming(),
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
