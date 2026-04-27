import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:provider/provider.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final GlobalKey screenshotKey = GlobalKey();

  String mostReadCategory = '...';
  Map<String, Map<String, int>> statsData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void loadStats() async {
    final mostRead = await BookService().getMostReadCategory();
    final stats = await BookService().getStatusCategoryStats();
    if (mounted) {
      setState(() {
        mostReadCategory = mostRead;
        statsData = stats;
        isLoading = false;
      });
    }
  }

  Future<void> captureAndSharePng() async {
    try {
      RenderRepaintBoundary? boundary =
          screenshotKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/reading_stats.png',
      ).create();
      await imagePath.writeAsBytes(pngBytes);

      final XFile xFile = XFile(imagePath.path);
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: context.watch<LanguageProvider>().translate(
            'สถิติการอ่านหนังสือของฉัน',
            'My Reading Stats',
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error capturing/sharing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      appBar: AppBar(
        backgroundColor: Appcolors.jetblackColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Appcolors.creamywhiteColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lp.translate('สถิติ', 'Statistics'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'supermarket',
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: screenshotKey,
                    child: Container(
                      color: Appcolors.jetblackColor,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Appcolors.copperColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  lp.translate(
                                    'ประเภทหนังสือที่อ่านมากที่สุด',
                                    'Most Read Categories',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontFamily: 'supermarket',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  mostReadCategory.isNotEmpty
                                      ? '$mostReadCategory!'
                                      : '-',
                                  style: TextStyle(
                                    color: Appcolors.creamywhiteColor,
                                    fontSize: 35,
                                    fontFamily: 'supermarket',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),

                          buildPieChartBlock(
                            'อ่านจบแล้ว',
                            lp.translate(
                              'หนังสือที่อ่านจบทั้งหมด',
                              'Total Finished Books',
                            ),
                            statsData['อ่านจบแล้ว'] ?? {},
                          ),
                          const SizedBox(height: 15),

                          buildHorizontalBarChartBlock(
                            'ยังไม่ได้อ่าน',
                            lp.translate(
                              'หนังสือที่ยังไม่ได้อ่านทั้งหมด',
                              'Total Unread Books',
                            ),
                            statsData['ยังไม่ได้อ่าน'] ?? {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  LoginButton(
                    text: lp.translate('แชร์', 'Share'),
                    height: 45,
                    width: 305,
                    color: Appcolors.copperColor,
                    textcolor: Appcolors.creamywhiteColor,
                    onPressed: captureAndSharePng,
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildPieChartBlock(
    String statusKey,
    String title,
    Map<String, int> categoriesMap,
  ) {
    int total = categoriesMap.values.fold(0, (sum, count) => sum + count);

    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];
    int index = 0;

    final List<Color> chartColors = [
      Color.fromRGBO(217, 217, 217, 225),
      Color.fromRGBO(197, 197, 197, 225),
      Color.fromRGBO(178, 178, 178, 225),
      Color.fromRGBO(158, 158, 158, 225),
      Color.fromRGBO(139, 139, 139, 225),
    ];

    categoriesMap.forEach((category, count) {
      if (count > 0) {
        final color = chartColors[index % chartColors.length];

        sections.add(
          PieChartSectionData(
            color: color,
            value: count.toDouble(),
            radius: 50,
            showTitle: false,
          ),
        );

        legendItems.add(
          Row(
            children: [
              Container(width: 10, height: 10, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'supermarket',
                  ),
                ),
              ),
            ],
          ),
        );
        index++;
      }
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Appcolors.copperColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: 'supermarket',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Appcolors.creamywhiteColor,
                fontSize: 22,
                fontFamily: 'supermarket',
              ),
              children: [
                TextSpan(
                  text: context.watch<LanguageProvider>().translate(
                    'หนังสือที่อ่านจบทั้งหมด ',
                    'Total Finished Books ',
                  ),
                ),
                TextSpan(
                  text: '$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: context.watch<LanguageProvider>().translate(
                    ' เล่ม ',
                    ' books',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalBarChartBlock(
    String statusKey,
    String title,
    Map<String, int> categoriesMap,
  ) {
    int total = categoriesMap.values.fold(0, (sum, count) => sum + count);
    int maxCount = categoriesMap.values.isNotEmpty
        ? categoriesMap.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Appcolors.copperColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: 'supermarket',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Appcolors.creamywhiteColor,
                fontSize: 20,
                fontFamily: 'supermarket',
              ),
              children: [
                TextSpan(text: '$title '),
                TextSpan(
                  text: '$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: context.watch<LanguageProvider>().translate(
                    ' เล่ม ',
                    ' books',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoriesMap.length,
            itemBuilder: (context, index) {
              String category = categoriesMap.keys.elementAt(index);
              int count = categoriesMap.values.elementAt(index);
              double barWidthFactor = count / maxCount;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'supermarket',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: barWidthFactor,
                            child: Container(
                              height: 15,
                              decoration: BoxDecoration(
                                color: Appcolors.lightgrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
