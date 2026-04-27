import 'package:flutter/material.dart';
import 'package:gongdong/model/font_provider.dart';
import 'package:provider/provider.dart';
import 'package:gongdong/navbar/shelf/bookdetail.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/widgets/booksscroll.dart';

class Scrollablebook extends StatelessWidget {
  final String text;
  final List<BookModel> itemCount;
  final double width;
  final double separatorwidth;
  final bool isScrollable;

  const Scrollablebook({
    super.key,
    required this.text,
    required this.itemCount,
    required this.width,
    required this.separatorwidth,
  }) : isScrollable = true;

  const Scrollablebook.noscroll({
    super.key,
    required this.text,
    required this.itemCount,
    required this.width,
    required this.separatorwidth,
  }) : isScrollable = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'supermarket',
              fontSize: 30 * context.watch<FontProvider>().fontSizeFactor,
              color: Color.fromARGB(255, 230, 230, 222),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Divider(
            color: Color.fromARGB(255, 230, 230, 222),
            thickness: 2,
          ),
        ),
        isScrollable
            ? SizedBox(
                height: 160,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: itemCount.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(width: separatorwidth);
                  },
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: width,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Bookdetail(itemCount: itemCount[index]);
                              },
                            ),
                          );
                        },
                        child: Booksscroll(image: itemCount[index].thumbnail),
                      ),
                    );
                  },
                ),
              )
            : Row(
                children: [
                  ...itemCount.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: SizedBox(
                        width: width,
                        height: 160,
                        child: Booksscroll(image: e.thumbnail),
                      ),
                    );
                  }),
                ],
              ),
        SizedBox(height: 20),
      ],
    );
  }
}
