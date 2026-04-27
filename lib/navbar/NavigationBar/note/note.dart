import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
//import 'package:gongdong/model/book_model.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/navbar/NavigationBar/note/notereal.dart';
import 'package:gongdong/style/app_style.dart';
//import 'package:gongdong/wishlist/wishlistinfo.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  List<GlobalKey> _boundaryKeys = [];
  final bookService = BookService();

  Future<void> shareNote(int index) async {
    try {
      RenderRepaintBoundary? boundary =
          _boundaryKeys[index].currentContext!.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(Duration(milliseconds: 50));
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/note_$index.png',
      ).create();
      await imagePath.writeAsBytes(pngBytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(imagePath.path)]),
      );
    } catch (e) {
      debugPrint('เกิดปัญหา $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 51, 50, 55),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 25, right: 25, top: 40, bottom: 10),
            child: Text(
              lp.translate('โน้ต', 'Notes'),
              style: TextStyle(
                fontFamily: 'supermarket',
                fontSize: 38,
                color: Appcolors.creamywhiteColor,
              ),
            ),
          ),
          Divider(color: Color.fromARGB(255, 230, 230, 222), thickness: 2),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: bookService.getAllNotes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                }
                final booksWithNotes = snapshot.data!;
                if (_boundaryKeys.length != booksWithNotes.length) {
                  _boundaryKeys = List.generate(
                    booksWithNotes.length,
                    (index) => GlobalKey(),
                  );
                }
                return ListView.builder(
                  itemCount: booksWithNotes.length,
                  itemBuilder: (context, index) {
                    final book = booksWithNotes[index];
                    return RepaintBoundary(
                      key: _boundaryKeys[index],
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              top: 20,
                              right: 20,
                              bottom: 10,
                            ),
                            padding: EdgeInsets.fromLTRB(20, 15, 85, 30),
                            decoration: BoxDecoration(
                              color: Appcolors.notelight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 100),
                                    Expanded(
                                      child: SizedBox(
                                        height: 75,
                                        child: Text(
                                          book['title'] ?? 'ไม่มีชื่อหนังสือ',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'supermarket',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                if (book['image_path'] != null &&
                                    book['image_path']!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: book['image_path']!
                                          .split(',')
                                          .map((url) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                url.trim(),
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          })
                                          .toList()
                                          .cast<Widget>(),
                                    ),
                                  ),
                                SizedBox(height: 10),
                                Text(
                                  book['content'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 36,
                            top: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(
                                book['thumbnail'],
                                width: 90,
                                height: 122,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 20,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Appcolors.jetblackColor,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Notereal(
                                        itemCount: BookModel(
                                          id: book['book_id'].toString(),
                                          title: book['title'] ?? '',
                                          thumbnail: book['thumbnail'] ?? '',
                                          authors: book['authors'] != null
                                              ? book['authors']
                                                    .toString()
                                                    .split(',')
                                              : [],
                                          description:
                                              book['description'] ?? '',
                                          pageCount: book['page_count'] ?? 0,
                                          category: book['category'] ?? '',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 60,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  shareNote(index);
                                },
                                icon: Icon(
                                  Icons.share,
                                  color: Appcolors.jetblackColor,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        lp.translate('ลบโน้ต', 'Delete Note'),
                                      ),
                                      content: Text(
                                        lp.translate(
                                          'คุณแน่ใจที่จะลบโน้ตนี้?',
                                          'Are you sure you want to delete this note?',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            lp.translate('ยกเลิก', 'Cancel'),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await bookService.deleteNote(
                                              book['book_id'].toString(),
                                            );
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Text(
                                            lp.translate(
                                              'ลบเลย!',
                                              'Delete Now',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Appcolors.jetblackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
