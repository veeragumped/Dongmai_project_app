import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/model/font_provider.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:gongdong/navbar/NavigationBar/account/challengetype.dart';
import 'package:gongdong/navbar/NavigationBar/account/static.dart';
import 'package:gongdong/navbar/shelf/bookinfoonshelf.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/challengewidget.dart';
import 'package:gongdong/widgets/dropdown.dart';
import 'package:gongdong/widgets/header.dart';
import 'package:gongdong/widgets/line.dart';
import 'package:flutter/material.dart';
import 'package:gongdong/widgets/size_box_setting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  List<Map<String, dynamic>> getChallenge = [];
  //List<BookModel>? _localFavItems;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      String? imageUrl = await BookService().uploadProfileImage(imageFile);
      if (imageUrl != null) {
        await BookService().updateProfileImage(imageUrl);
        if (mounted) setState(() {});
      }
    }
  }

  void _editNameDialog(String currentName) {
    final lp = context.read<LanguageProvider>();
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Appcolors.jetblackColor,
        title: Text(
          lp.translate("แก้ไขชื่อผู้ใช้", "Edit Username"),
          style: const TextStyle(color: Colors.white, fontFamily: 'print'),
        ),
        content: TextField(
          maxLength: 8,
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Appcolors.copperColor),
            ),
            hintText: lp.translate("พิมพ์ชื่อใหม่ที่นี่", "Type new name here"),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              lp.translate("ยกเลิก", "Cancel"),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await BookService().updateUsername(nameController.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(
              lp.translate("บันทึก", "Save"),
              style: TextStyle(color: Appcolors.copperColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    final fontFactor = context.watch<FontProvider>().fontSizeFactor;

    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Container(height: 120, color: Appcolors.copperColor),
                  Container(height: 23, color: Appcolors.creamywhiteColor),
                ],
              ),
              Positioned(
                left: 15,
                bottom: -13,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(BookService().uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String name = "User";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null && data.containsKey('username')) {
                        name = data['username'] ?? "User";
                      }
                    }
                    return Stack(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'inter',
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = const Color.fromARGB(255, 100, 80, 50),
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 40,
                            fontFamily: 'inter',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                right: 20,
                top: 40,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(BookService().uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String? imageUrl;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      if (data.containsKey('profileImage'))
                        imageUrl = data['profileImage'];
                    }
                    return GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        width: 155,
                        height: 155,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/User_Profile.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: Row(
              children: [
                Text(
                  lp.translate('ชื่อผู้ใช้', 'Username'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'print',
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _editNameDialog("User");
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 20),
            child: Text(
              lp.translate('หนังสือโปรด', 'Favorites'),
              style: TextStyle(
                color: Appcolors.creamywhiteColor,
                fontSize: 40 * fontFactor,
                fontFamily: 'print',
                height: 1,
              ),
            ),
          ),
          Row(children: [Line(top: 0, left: 20, width: 365)]),
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset('assets/images/fav_shelf.png', width: 365),
                Positioned(
                  bottom: 15,
                  child: SizedBox(
                    height: 100,
                    width: 365,
                    child: StreamBuilder<List<BookModel>>(
                      stream: BookService().getFavoriteBooks(),
                      builder: (context, snapshot) {
                        final favBooks = snapshot.data ?? [];
                        if (!snapshot.hasData || favBooks.isEmpty)
                          return const SizedBox();
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favBooks.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Bookinfoonshelf(
                                    itemCount: favBooks[index],
                                  ),
                                ),
                              ).then((_) => setState(() {})),
                              child: Image.network(
                                favBooks[index].thumbnail,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Text(
              lp.translate('ชาเลนจ์', 'Challenge'),
              style: TextStyle(
                color: Appcolors.creamywhiteColor,
                fontSize: 40 * fontFactor,
                fontFamily: 'print',
                height: 1,
              ),
            ),
          ),
          Row(children: [Line(top: 0, left: 20, width: 365)]),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: BookService().getChallenge(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      lp.translate('ยังไม่มีภารกิจ', 'No Challenge'),
                      style: TextStyle(
                        color: Appcolors.lightgrey,
                        fontSize: 30,
                        fontFamily: 'supermarket',
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: snapshot.data!
                    .map(
                      (item) => Challengewidget(
                        id: item['id'] ?? 0,
                        title: item['title'] ?? 'N/A',
                        currentCount:
                            int.tryParse(item['current_count'].toString()) ?? 0,
                        goalCount:
                            int.tryParse(item['goal_count'].toString()) ?? 0,
                        onRefresh: () => setState(() {}),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Challengetype()),
              ).then((_) => setState(() {})),
              style: TextButton.styleFrom(
                backgroundColor: Appcolors.copperColor,
                foregroundColor: Appcolors.creamywhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                lp.translate('เพิ่มชาเลนจ์', 'Add Challenge'),
                style: TextStyle(
                  fontFamily: 'supermarket',
                  fontSize: 25 * fontFactor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Text(
              lp.translate('สถิติ', 'Statistics'),
              style: TextStyle(
                color: Appcolors.creamywhiteColor,
                fontSize: 40 * fontFactor,
                fontFamily: 'print',
                height: 1,
              ),
            ),
          ),
          Row(children: [Line(top: 0, left: 20, width: 365)]),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<Map<String, int>>(
              future: _loadAllStatusCounts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final read = snapshot.data!['อ่านจบแล้ว'] ?? 0;
                final reading = snapshot.data!['กำลังอ่าน'] ?? 0;
                final notRead = snapshot.data!['ยังไม่ได้อ่าน'] ?? 0;
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticPage(),
                    ),
                  ).then((_) => setState(() {})),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Appcolors.copperColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lp.translate(
                            'สรุปการอ่านของคุณ',
                            'Your reading summary',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontFamily: 'supermarket',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildSmallPieChartSections(
                                    read,
                                    reading,
                                    notRead,
                                  ),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  buildStatText(
                                    lp.translate('อ่านจบแล้ว', 'Finished'),
                                    read,
                                    Colors.white,
                                    Colors.white,
                                  ),
                                  buildStatText(
                                    lp.translate('กำลังอ่าน', 'Reading'),
                                    reading,
                                    Colors.white,
                                    const Color(0xFFBDBDBD),
                                  ),
                                  buildStatText(
                                    lp.translate('ยังไม่อ่าน', 'Not Read'),
                                    notRead,
                                    Colors.white,
                                    const Color(0xFF424242),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Text(
              lp.translate('ตั้งค่า', 'Settings'),
              style: TextStyle(
                color: Appcolors.creamywhiteColor,
                fontSize: 40 * fontFactor,
                fontFamily: 'print',
                height: 1,
              ),
            ),
          ),
          Row(children: [Line(top: 0, left: 20, width: 365)]),

          Header(
            title: lp.translate('บัญชี', 'Account'),
            padding: 40,
            fontsize: 30 * context.watch<FontProvider>().fontSizeFactor,
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: false,
                backgroundColor: Appcolors.jetblackColor,
                showDragHandle: false,
                context: context,
                builder: (context) {
                  return Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: Appcolors.jetblackColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          lp.translate('ข้อมูลบัญชี', 'Account Information'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'print',
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 104,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Appcolors.copperColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                top: 50,
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(BookService().uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    String? imageUrl;
                                    if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      final data =
                                          snapshot.data!.data()
                                              as Map<String, dynamic>;
                                      if (data.containsKey('profileImage')) {
                                        imageUrl = data['profileImage'];
                                      }
                                    }
                                    return GestureDetector(
                                      onTap: _pickAndUploadImage,
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipOval(
                                              child:
                                                  imageUrl != null &&
                                                      imageUrl.isNotEmpty
                                                  ? Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: 120,
                                                      height: 120,
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      colorBlendMode:
                                                          BlendMode.darken,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/User_Profile.png',
                                                      fit: BoxFit.cover,
                                                      width: 120,
                                                      height: 120,
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      colorBlendMode:
                                                          BlendMode.darken,
                                                    ),
                                            ),
                                            const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 180,
                                left: 0,
                                right: 0,
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(BookService().uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    String currentName =
                                        snapshot.hasData &&
                                            snapshot.data!.exists
                                        ? (snapshot.data!.get('username') ??
                                              "User")
                                        : "Froggy";
                                    return Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 50,
                                          ),
                                          child: Text(
                                            'ชื่อ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontFamily: 'print',
                                            ),
                                          ),
                                        ),
                                        Text(
                                          currentName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontFamily: 'print',
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _editNameDialog(currentName),
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Line(top: 0, left: 40, width: 350),
          Header(
            title: lp.translate('ขนาดตัวอักษรและภาษา', 'Font & Language'),
            padding: 40,
            fontsize: 30 * fontFactor,
            onTap: () => _showSettingsModal(context),
          ),
          Line(top: 0, left: 40, width: 350),
          Header(
            title: lp.translate('ออกจากระบบ', 'Log Out'),
            padding: 40,
            fontsize: 30 * fontFactor,
            onTap: () => showLogoutDialog(context),
          ),
          Line(top: 0, left: 40, width: 350),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Appcolors.jetblackColor,
      context: context,
      builder: (context) {
        final lp = context.watch<LanguageProvider>();
        final fontProv = context.watch<FontProvider>();
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lp.translate('ตั้งค่า', 'Settings'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontFamily: 'print',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lp.translate('ขนาดตัวอักษร', 'Font Size'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'print',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => fontProv.setFontSize(0.8),
                    child: SizeBoxSetting(
                      text: 'ก',
                      fontsize: 25,
                      textUnder: lp.translate('เล็ก', 'Small'),
                      boxcolor: fontProv.fontSizeFactor == 0.8
                          ? Colors.white
                          : Appcolors.copperColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => fontProv.setFontSize(1.0),
                    child: SizeBoxSetting(
                      text: 'ก',
                      fontsize: 35,
                      textUnder: lp.translate('กลาง', 'Med'),
                      boxcolor: fontProv.fontSizeFactor == 1.0
                          ? Colors.white
                          : Appcolors.copperColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => fontProv.setFontSize(1.2),
                    child: SizeBoxSetting(
                      text: 'ก',
                      fontsize: 45,
                      textUnder: lp.translate('ใหญ่', 'Large'),
                      boxcolor: fontProv.fontSizeFactor == 1.2
                          ? Colors.white
                          : Appcolors.copperColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                lp.translate('ภาษา', 'Language'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'print',
                ),
              ),
              Dropdown(
                items: const ['english', 'ไทย'],
                label: Text(lp.translate('เลือกภาษา', 'Select Language')),
                onchanged: (v) {
                  if (v != null) lp.setLanguage(v);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    final lp = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Appcolors.notelight,
        title: Text(
          lp.translate('ยืนยันการออกจากระบบ', 'Log Out'),
          style: const TextStyle(fontFamily: 'supermarket'),
        ),
        content: Text(
          lp.translate(
            'ต้องการออกจากระบบใช่หรือไม่?',
            'Are you sure you want to log out?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              lp.translate('ยกเลิก', 'Cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await BookService().signOut();
              if (context.mounted)
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Text(
              lp.translate('ตกลง', 'OK'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatText(
    String label,
    int value,
    Color color,
    Color circleColor,
  ) {
    return Row(
      children: [
        Icon(Icons.square, size: 10, color: circleColor),
        const SizedBox(width: 10),
        Text(
          '$label $value ${context.read<LanguageProvider>().translate('เล่ม', 'books')}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontFamily: 'print',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<Map<String, int>> _loadAllStatusCounts() async {
    final read = await BookService().countBooksByStatus('อ่านจบแล้ว');
    final reading = await BookService().countBooksByStatus('กำลังอ่าน');
    final notRead = await BookService().countBooksByStatus('ยังไม่ได้อ่าน');
    return {'อ่านจบแล้ว': read, 'กำลังอ่าน': reading, 'ยังไม่ได้อ่าน': notRead};
  }

  List<PieChartSectionData> _buildSmallPieChartSections(
    int read,
    int reading,
    int notRead,
  ) {
    if (read == 0 && reading == 0 && notRead == 0)
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          radius: 25,
          showTitle: false,
        ),
      ];
    return [
      PieChartSectionData(
        color: Colors.white,
        value: read.toDouble(),
        radius: 25,
        showTitle: false,
      ),
      PieChartSectionData(
        color: const Color(0xFFBDBDBD),
        value: reading.toDouble(),
        radius: 25,
        showTitle: false,
      ),
      PieChartSectionData(
        color: const Color(0xFF424242),
        value: notRead.toDouble(),
        radius: 25,
        showTitle: false,
      ),
    ];
  }
}
