import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_icons/flutter_custom_icons.dart';
import 'package:gongdong/navbar/NavigationBar/account/account.dart';
import 'package:gongdong/navbar/home/home.dart';
import 'package:gongdong/navbar/NavigationBar/note/note.dart';
import 'package:gongdong/navbar/random/random.dart';
import 'package:gongdong/navbar/shelf/shelf.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentPageIndex = 0;

  List<Widget> pages = [Home(), Note(), Shelf(), Random(), Account()];

  List<TabItem> items(BuildContext context) {
    return [
      TabItem(
        icon: Icons.home,
        title: context.watch<LanguageProvider>().translate('หน้าแรก', 'Home'),
      ),
      TabItem(
        icon: Iconixto.note,
        title: context.watch<LanguageProvider>().translate('โน้ต', 'Notes'),
      ),
      TabItem(
        icon: Icons.menu_book,
        title: context.watch<LanguageProvider>().translate(
          'ชั้นหนังสือ',
          'Bookshelf',
        ),
      ),
      TabItem(
        icon: Iconixto.dice,
        title: context.watch<LanguageProvider>().translate('สุ่มวงล้อ', 'Spin'),
      ),
      TabItem(
        icon: Icons.account_circle,
        title: context.watch<LanguageProvider>().translate('บัญชี', 'Account'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: BottomBarDivider(
        items: items(context),
        backgroundColor: Appcolors.copperColor,
        color: Appcolors.jetblackColor,
        colorSelected: Appcolors.creamywhiteColor,
        indexSelected: currentPageIndex,
        top: 20,
        animated: true,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        titleStyle: TextStyle(fontFamily: 'supermarket', fontSize: 19),
        styleDivider: StyleDivider.top,
        iconSize: 24,
      ),
    );
  }
}
