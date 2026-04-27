import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/navbar/shelf/addbook.dart';
import 'package:gongdong/navbar/shelf/bookinfoonshelf.dart';
//import 'package:gongdong/navbar/shelf/bookinfoonshelf.dart';
import 'package:gongdong/navbar/shelf/booksearchonshelf.dart';
import 'package:gongdong/navbar/shelf/deco.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/deco_picker.dart';
import 'package:gongdong/widgets/placement_slot.dart';
import 'package:gongdong/widgets/shelf_bg.dart';
//import 'package:gongdong/model/db.dart';
//import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/wishlist/wishlist.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_custom_icons/flutter_custom_icons.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Shelf extends StatefulWidget {
  const Shelf({super.key});

  @override
  State<Shelf> createState() => _ShelfState();
}

class _ShelfState extends State<Shelf> {
  List<Map<String, dynamic>>? _localShelfItems;
  bool isEditMode = false;
  int shelfCount = 1;
  String currentShelfPath = 'assets/images/shelfbg.png';

  Future<void> handleSlotTap(int position) async {
    final selectedItem = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DecoPicker(),
    );

    if (selectedItem != null) {
      await BookService().insertDecorationToShelf(
        itemId: selectedItem['id'] ?? selectedItem['item_ref_id'],
        position: position,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  void addShelf() {
    setState(() {
      shelfCount++;
    });
  }

  @override
  void initState() {
    super.initState();
    //DBHelper().syncInitialBooksToShelf().then((_) {
    //setState(() {
    loadEquippedShelf();
    //});
    // });
  }

  void loadEquippedShelf() async {
    final bookService = BookService();
    try {
      String shelfImg = await bookService.getEquippedShelfImage();
      if (mounted) {
        setState(() {
          currentShelfPath = shelfImg.isNotEmpty
              ? shelfImg
              : 'assets/images/shelfbg.png';
        });
      }
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      body: ListView(
        children: [
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 10,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isEditMode = !isEditMode;
                    });
                  },
                  icon: Icon(
                    isEditMode ? Icons.check_circle : Iconixto.hammerSolid,
                    color: isEditMode
                        ? Colors.green
                        : Appcolors.creamywhiteColor,
                  ),
                ),
              ),
              Text(
                lp.translate('ชั้นหนังสือ', 'Bookshelf'),
                style: TextStyle(
                  fontFamily: 'supermarket',
                  color: Appcolors.creamywhiteColor,
                  fontSize: 40,
                ),
              ),
              Positioned(
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Deco();
                            },
                          ),
                        ).then((_) {
                          loadEquippedShelf();
                        });
                      },
                      icon: Icon(
                        Icons.shopping_bag,
                        color: Appcolors.creamywhiteColor,
                      ),
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
                        ).then((_) => setState(() {}));
                      },
                      icon: Icon(Icons.add, color: Appcolors.creamywhiteColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Color.fromARGB(255, 230, 230, 222), thickness: 2),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Wishlist();
                        },
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Icon(
                          Icons.star,
                          color: Appcolors.creamywhiteColor,
                          size: 26,
                        ),
                      ),
                      Text(
                        lp.translate('รายการโปรด', 'Wishlist'),
                        style: TextStyle(
                          color: Color.fromARGB(255, 230, 230, 222),
                          fontSize: 30,
                          fontFamily: 'supermarket',
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Booksearchonshelf(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.search_rounded,
                    size: 28,
                    color: Appcolors.creamywhiteColor,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: BookService().getShelfContent(),
                builder: (context, snapshot) {
                  final shelfItems = snapshot.data ?? [];

                  if (_localShelfItems == null ||
                      _localShelfItems!.length != shelfItems.length) {
                    _localShelfItems = shelfItems;
                  }

                  final displayItems = _localShelfItems!;

                  int autoShelfCount = (shelfItems.length / 12).ceil();
                  if (autoShelfCount < 1) autoShelfCount = 1;
                  int finalCount = (autoShelfCount > shelfCount)
                      ? autoShelfCount
                      : shelfCount;

                  return Stack(
                    children: [
                      Column(
                        children: [
                          for (int i = 0; i < finalCount; i++)
                            ShelfBg(imagePaths: currentShelfPath),
                        ],
                      ),
                      if (shelfItems.isNotEmpty)
                        ReorderableBuilder<Map<String, dynamic>>(
                          key: ValueKey(shelfItems.length),
                          onReorder: (reorderedListFunction) {
                            final reorderedList = reorderedListFunction(
                              displayItems,
                            );
                            setState(() {
                              _localShelfItems = reorderedList;
                            });
                            BookService().updateAllPositions(reorderedList);
                          },
                          builder: (reorderableChildren) {
                            return GridView(
                              clipBehavior: Clip.none,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                top: 5,
                                right: 20,
                                left: 20,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisExtent: 197.5,
                                  ),
                              children: reorderableChildren,
                            );
                          },
                          children: List.generate(shelfItems.length, (index) {
                            final item = displayItems[index];
                            final String type = item['item_type'];

                            return GestureDetector(
                              key: ValueKey(item['id']),
                              onTap: () async {
                                if (!isEditMode && type == 'book') {
                                  final String? bookId = item['item_ref_id']
                                      ?.toString();
                                  if (bookId == null) return;
                                  final bookData = await BookService()
                                      .getBookById(bookId)
                                      .first;

                                  if (bookData != null && context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Bookinfoonshelf(
                                          itemCount: bookData,
                                        ),
                                      ),
                                    ).then((_) => setState(() {}));
                                  }
                                }
                              },

                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 25,
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: type == 'book'
                                          ? (item['display_img'] != null &&
                                                    item['display_img']
                                                        .toString()
                                                        .isNotEmpty)
                                                ? Image.network(
                                                    item['display_img'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                        ),
                                                  )
                                                : Container(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.3),
                                                  )
                                          : (item['display_img'] != null &&
                                                item['display_img']
                                                    .toString()
                                                    .isNotEmpty)
                                          ? Image.asset(
                                              item['display_img'],
                                              fit: BoxFit.contain,
                                            )
                                          : const SizedBox(),
                                    ),
                                  ),
                                  if (isEditMode)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () async {
                                          await BookService()
                                              .removeFromShelfById(
                                                item['id'],
                                                item['item_ref_id'],
                                              );
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),

                      if (isEditMode) ...[
                        for (int i = 0; i < autoShelfCount * 4; i++) ...[
                          PlacementSlot(
                            top: (i * 197.5) + 80,
                            left: MediaQuery.of(context).size.width * 0.15,
                            onTap: () => handleSlotTap(i * 3),
                          ),
                          PlacementSlot(
                            top: (i * 197.5) + 80,
                            right: (MediaQuery.of(context).size.width / 2) - 25,
                            onTap: () => handleSlotTap((i * 3) + 1),
                          ),
                          PlacementSlot(
                            top: (i * 197.5) + 80,
                            right: MediaQuery.of(context).size.width * 0.15,
                            onTap: () => handleSlotTap((i * 3) + 2),
                          ),
                        ],
                      ],
                    ],
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
