import 'package:flutter/material.dart';
import 'package:gongdong/navbar/shelf/bookdetail.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/style/app_style.dart';

class Booksearchver extends StatelessWidget {
  final List<BookModel> searchBooks;

  const Booksearchver({super.key, required this.searchBooks});

  Widget _buildnoImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Appcolors.creamywhiteColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.book), Text('ไม่มีรูปปก')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: 0.65,
      ),
      itemCount: searchBooks.length,
      itemBuilder: (context, index) {
        final book = searchBooks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Bookdetail(itemCount: book);
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (book.thumbnail.isNotEmpty)
                      ? Image.network(
                          book.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildnoImage(),
                        )
                      : _buildnoImage(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'supermarket',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
