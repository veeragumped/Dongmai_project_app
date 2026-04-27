import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:gongdong/service/storage_service.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Notereal extends StatefulWidget {
  final BookModel itemCount;

  const Notereal({super.key, required this.itemCount});

  @override
  State<Notereal> createState() => _NoterealState();
}

class _NoterealState extends State<Notereal> {
  final TextEditingController _controller = TextEditingController();
  //final DBHelper dbHelper = DBHelper();
  List<String> imageUrls = [];
  final _storageService = StorageService();

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      for (var xfile in images) {
        File file = File(xfile.path);
        String url = await _storageService.uploadNoteImage(file);

        if (url.isNotEmpty) {
          setState(() {
            imageUrls.add(url);
          });
        }
      }
      _saveCurrentData();
    }
  }

  void _saveCurrentData() {
    String allUrls = imageUrls.join(',');
    BookService().saveNotes(widget.itemCount.id, _controller.text, allUrls);
  }

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    if (widget.itemCount.id.isEmpty) return;
    Map<String, dynamic>? noteData = await BookService().getNotes(
      widget.itemCount.id,
    );

    if (noteData != null && mounted) {
      setState(() {
        _controller.text = noteData['content'] ?? '';
        String savedUrls =
            noteData['image_url'] ?? noteData['image_path'] ?? '';
        if (savedUrls.isNotEmpty) {
          imageUrls = savedUrls.split(',');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Appcolors.notelight,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: pickImage,
                icon: Icon(Icons.add_photo_alternate),
              ),
            ],
          ),
        ),
        backgroundColor: Appcolors.noteheavy,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Image.network(widget.itemCount.thumbnail, width: 100),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.itemCount.title,
                      style: TextStyle(
                        fontFamily: 'supermarket',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (imageUrls.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 1),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  runSpacing: 8,
                  children: imageUrls.map((url) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey,
                                  child: Icon(Icons.broken_image),
                                ),
                          ),
                        ),
                        Positioned(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                imageUrls.remove(url);
                              });
                              _saveCurrentData();
                            },
                            child: Icon(Icons.cancel),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                style: TextStyle(fontFamily: 'thonburi', fontSize: 18),
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontFamily: 'supermarket', fontSize: 18),
                  hintText: lp.translate(
                    'เขียนโน้ตที่นี่...',
                    'Write your note here...',
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _saveCurrentData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
