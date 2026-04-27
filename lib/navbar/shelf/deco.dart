import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/decobutton.dart';
import 'package:gongdong/widgets/itemindeco.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Deco extends StatefulWidget {
  const Deco({super.key});

  @override
  State<Deco> createState() => _DecoState();
}

class _DecoState extends State<Deco> {
  String seletecedShelf = 'Original';
  List<String> equippedItems = [];
  final List<Map<String, dynamic>> shelve = [
    {'name': 'ชั้นหนังสือสีน้ำเงิน', 'img': 'assets/images/shelfbg_blue.png'},
    {'name': 'ชั้นหนังสือสีขาว', 'img': 'assets/images/shelfbg_white.png'},
    {'name': 'ชั้นหนังสือสีแดง', 'img': 'assets/images/shelfbg_red.png'},
    {'name': 'ชั้นหนังสือสีม่วัย', 'img': 'assets/images/shelfbg_purple.png'},
    {'name': 'ชั้นหนังสือสีเขียว', 'img': 'assets/images/shelfbg_green.png'},
  ];
  final List<Map<String, dynamic>> dolls = [
    {'name': 'หมามะพร้าว', 'img': 'assets/images/cabi_doll.png'},
    {'name': 'เป็ด', 'img': 'assets/images/duck_doll.png'},
    {'name': 'เป็ดน้อย', 'img': 'assets/images/littleduck_doll.png'},
    {'name': 'หม้อ', 'img': 'assets/images/potty_doll.png'},
    {'name': 'ช้าง', 'img': 'assets/images/elephat_doll.png'},
  ];
  final List<Map<String, dynamic>> trees = [
    {'name': 'ทิวลิป', 'img': 'assets/images/cactus.png'},
    {'name': 'อาชัว', 'img': 'assets/images/azure.png'},
    {'name': 'ลิลลี่', 'img': 'assets/images/lily.png'},
    {'name': 'อัลเลียม', 'img': 'assets/images/allium.png'},
    {'name': 'เชอร์รี่', 'img': 'assets/images/cherry_sapling.png'},
    {'name': 'เฟิร์น', 'img': 'assets/images/Fern.png'},
  ];
  List<String> ownedItems = [];
  int userDiamonds = 0;

  void onBuyItem(String name, String category, img, int price) async {
    bool success = await BookService().spendDiamonds(
      name,
      category,
      img,
      price,
    );
    if (success) {
      loadItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().translate(
                'ซื้อ $name สำเร็จ',
                'Purchased $name successfully',
              ),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().translate(
                'เพชรไม่พอ',
                'Not enough diamonds',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadItems();
  }

  void loadItems() async {
    await loadUserDiamonds();

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(BookService().uid)
        .collection('inventory')
        .get();

    if (mounted) {
      setState(() {
        ownedItems = snapshot.docs
            .map((doc) => doc['item_name'] as String)
            .toList();
        equippedItems.clear();

        for (var doc in snapshot.docs) {
          var data = doc.data();
          if (data['is_equipped'] == true) {
            String name = data['item_name'];
            String category = data['category'];
            if (category == 'ชั้นหนังสือ') {
              seletecedShelf = name;
            } else {
              equippedItems.add(name);
            }
          }
        }
      });
    }
  }

  Future<void> loadUserDiamonds() async {
    int current = await BookService().getDiamonds().first;
    if (mounted) {
      setState(() {
        userDiamonds = current;
      });
    }
  }

  String selectedTab = 'ชั้นหนังสือ';

  @override
  Widget build(BuildContext context) {
    var lp = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      appBar: AppBar(
        backgroundColor: Appcolors.jetblackColor,
        foregroundColor: Appcolors.creamywhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: StreamBuilder<int>(
              stream: BookService().getDiamonds(),
              builder: (context, snapshot) {
                final diamonds = snapshot.data ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.diamond_sharp, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      '$diamonds',
                      style: const TextStyle(
                        fontFamily: 'supermarket',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Divider(color: Appcolors.creamywhiteColor, thickness: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tabButton(
                      'ชั้นหนังสือ',
                      lp.translate('ชั้นหนังสือ', 'Bookshelf'),
                      15,
                      15,
                    ),
                    tabButton(
                      'ของตกแต่ง',
                      lp.translate('ของตกแต่ง', 'Decoration'),
                      15,
                      15,
                    ),
                    tabButton('ต้นไม้', lp.translate('ต้นไม้', 'Tree'), 35, 35),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: tabItems(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(String key, String label, double left, double right) {
    bool isSelected = selectedTab == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = key;
        });
      },
      child: Decobutton(
        text: label,
        left: left,
        right: right,
        top: 10,
        bottom: 10,
        boxcolor: isSelected ? Appcolors.jetblackColor : Appcolors.lightgrey,
        textcolor: isSelected ? Appcolors.lightgrey : Appcolors.jetblackColor,
      ),
    );
  }

  Widget tabItems() {
    List<Map<String, dynamic>> currentList;
    if (selectedTab == 'ชั้นหนังสือ') {
      currentList = shelve;
    } else if (selectedTab == 'ของตกแต่ง') {
      currentList = dolls;
    } else {
      currentList = trees;
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        mainAxisExtent: 270,
        crossAxisSpacing: 15,
      ),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        var item = currentList[index];
        String itemName = item['name'];
        bool isOwned = ownedItems.contains(itemName);
        bool isSelected =
            (selectedTab == 'ชั้นหนังสือ' && seletecedShelf == itemName);

        return Itemindeco(
          category: selectedTab,
          imageurl: item['img'],
          bottom: 5,
          onTap: () async {
            if (isOwned) {
              if (selectedTab == 'ชั้นหนังสือ') {
                setState(() => seletecedShelf = itemName);
                await BookService().equippedItem(
                  itemName,
                  item['img'],
                  'ชั้นหนังสือ',
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<LanguageProvider>().translate(
                        'คุณมี $itemName อยู่ในคลังแล้ว',
                        'You already have $itemName in your inventory',
                      ),
                    ),
                  ),
                );
              }
            } else {
              onBuyItem(itemName, selectedTab, item['img'], 50);
            }
          },
          isOwned: isOwned,
          isSelected: isSelected,
        );
      },
    );
  }
}
