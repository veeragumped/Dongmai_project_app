import 'package:flutter/material.dart';
import 'package:gongdong/model/book_model.dart';
import 'package:gongdong/model/book_service.dart';
import 'package:gongdong/model/font_provider.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/widgets/scrollablebook.dart';
import 'package:gongdong/wishlist/wishlist.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/customcard.dart';
import 'package:provider/provider.dart';
import 'package:gongdong/model/language_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;

  BookService bookService = BookService();
  List<BookModel> trendingBooks = [];
  List<BookModel> topHitsBooks = [];
  List<BookModel> newBooks = [];
  List<BookModel> allBooks = [];
  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  void loadBooks() async {
    setState(() {
      isLoading = true;
    });

    var trending = await bookService.fetchBooks('Trending+หนังสือ');
    var hits = await bookService.fetchBooks('หนังสือยอดฮิต');
    var latest = await bookService.fetchBooks('2569+2026');

    if (!mounted) return;

    setState(() {
      trendingBooks = trending;
      topHitsBooks = hits;
      newBooks = latest;
      isLoading = false;
    });
    debugPrint('โหลดหนังสือกำลังมาแรงสำเร็จ: ${trendingBooks.length} เล่ม');
    debugPrint('โหลดหนังสือฮิตติดท็อปสำเร็จ: ${hits.length} เล่ม');
    debugPrint('โหลดหนังสือมาใหม่สำเร็จ: ${latest.length} เล่ม');
  }

  Future<void> url(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 51, 50, 55),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 40,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    lp.translate('ข่าวสาร', 'News'),
                    style: TextStyle(
                      fontFamily: 'supermarket',
                      fontSize: 38,
                      color: Appcolors.creamywhiteColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                              lp.translate('Wishlist', 'Wishlist'),
                              style: TextStyle(
                                color: Appcolors.creamywhiteColor,
                                fontSize:
                                    30 *
                                    context
                                        .watch<FontProvider>()
                                        .fontSizeFactor,
                                fontFamily: 'supermarket',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Color.fromARGB(255, 230, 230, 222), thickness: 2),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomCard(
                  onTap: () => url(
                    'https://web.facebook.com/BookFairTH/posts/pfbid0g7PwzXFHGsRtrGJcgNf6wCBQxi4A412SJ745cPWreKi8Sh6vdMQd4ojYSSpreitnl',
                  ),
                  image:
                      'https://scontent.fbkk3-3.fna.fbcdn.net/v/t39.30808-6/674956860_947066144782064_5082374744990494820_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=13d280&_nc_eui2=AeF9aWrJ49nRw69ADbyszGeCxJl04I1vYRDEmXTgjW9hEHEYnkhZW0YBir0zcbHy6wZyqklN3YptoVGc51CQOgcb&_nc_ohc=cuLazDGA3G8Q7kNvwH027G1&_nc_oc=AdoYwQQKutmwY9FOX8kYfsAuoNQGNPUnYCc1qX6vjjTXyZB3uf55kIKFvOjCOaemW8k&_nc_zt=23&_nc_ht=scontent.fbkk3-3.fna&_nc_gid=vAXdyWoDIB7YbTXVDycWYA&_nc_ss=7b2a8&oh=00_Af32XZM-vWzUL4Hvxc35_HmVsR6vc-wicTk4gMF7Ipvk-A&oe=69F4999C',
                  title: 'โคราช บุ๊คแฟร์ ครั้งที่ 1',
                  description:
                      'Korat Book Fair #1 วันที่ 8 – 17 พฤษภาคม 2569 เวลา 10.00 – 21.00 น. ณ โคราช ฮอลล์ ชั้น 4 ศูนย์การค้าเซ็นทรัล โคราช จังหวัดนครราชสีมา',
                ),
                CustomCard(
                  onTap: () => url(
                    'https://thestandard.co/15-new-books-must-have-on-national-book-week-online/',
                  ),
                  image:
                      //'https://scontent.fbkk15-1.fna.fbcdn.net/v/t39.30808-6/645470791_1337989228365824_2287847225900976992_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=105&ccb=1-7&_nc_sid=13d280&_nc_eui2=AeGiAEoLwT5k-3CKR6v56bVugm8gwws3KiCCbyDDCzcqIFQe5liPqYPVB8_1b6yQHUF4iYiVQo-whRM4VSAqO_Zi&_nc_ohc=jfiidfEr_bYQ7kNvwEtelLP&_nc_oc=AdmbhIjzCbokjXSXz65F5Sbr1stqQ75BrCVe62ooSkvT2qBazfWZh26IVJO4ueQ2chg&_nc_zt=23&_nc_ht=scontent.fbkk15-1.fna&_nc_gid=Dy8flj2Ue7NN7l8ausJHXw&_nc_ss=8&oh=00_AfwFd31MmZ284qo644_wtxouqOOBIPuBnpqOdMQefqNGTg&oe=69B2C15E',
                      'https://thestandard.co/wp-content/uploads/2020/03/COVER-WEB-239.jpg',
                  title:
                      'หนังสือใหม่ 15 เล่มที่ควรซื้อจากงานสัปดาห์หนังสือแห่งชาติออนไลน์',
                  description:
                      'สำหรับคนที่ยังลังเล ไม่รู้ว่าจะซื้อเล่มไหนดี The Standard ขอแนะนำหนังสือใหม่ 15 เล่ม หลากหลายรูปแบบเนื้อหา',
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomCard(
                  onTap: () => url(
                    'https://web.facebook.com/photo?fbid=824221443785413',
                  ),
                  image:
                      'https://scontent.fbkk3-1.fna.fbcdn.net/v/t39.30808-6/591414425_824221447118746_7780624084412099703_n.jpg?stp=dst-jpg_p526x296_tt6&_nc_cat=109&ccb=1-7&_nc_sid=13d280&_nc_eui2=AeEZPm8PHTiiGPtMKCUHeufxe4CaUHytvZR7gJpQfK29lPiL2qMOtrjTOHnt4jcg8qig9fit9HnbcJWgj7euwMNE&_nc_ohc=MLcyhxQ-urgQ7kNvwEhrOBl&_nc_oc=AdqXeCau3pGJ5MuI8XGOBRYm053Hq9m3s8NkBu9rq19VHCmsAl5UD00IrAm0uPsjLG0&_nc_zt=23&_nc_ht=scontent.fbkk3-1.fna&_nc_gid=CFH4630Cb0RDxGtDO_0LPQ&_nc_ss=7b2a8&oh=00_Af0yG2vsYNss8hI_bkjorCP3YIi08AuwVf9oPfFQUlZxCw&oe=69F483D4',
                  //'https://shoppinglist.xiteb.com/assets/uploads/vendors/1719571780.jpg',
                  title: 'โปรดจงรู้ไว้ ความรุนแรงไม่ใข่อารมณ์',
                  description:
                      'เมื่อเกือบ 30 ปีที่แล้ว มนุษย์มีข้อถกเถียงเรื่องสิทธิครอบครองปืนในสหรัฐ ณ ปัจจุบัน มนุษย์ก็ยังคงถกเถียงเรื่องการครอบครองปืนในสหรัฐอยู่เช่นเดิม ',
                ),
                CustomCard(
                  onTap: () => url(
                    'https://web.facebook.com/photo/?fbid=1647765034023241',
                  ),
                  image:
                      //'https://scontent.fbkk15-1.fna.fbcdn.net/v/t39.30808-6/646490229_1398034525671793_6359020911968657772_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=13d280&_nc_eui2=AeF_tYHgadQVH_zajWoHxzxleG02uGApSbl4bTa4YClJualBVemX89pe-Sf8EYk8Utp37rh8EX21ha7KwodAuwpG&_nc_ohc=d5DWGZcZ1A0Q7kNvwE_WeGa&_nc_oc=AdmI1u5suW9NnW7ttSy1dwU2XmUsfwmFmnHDNwGcHJcPDYwjwzM5yHaz5-UgEjzHODE&_nc_zt=23&_nc_ht=scontent.fbkk15-1.fna&_nc_gid=zDI24oLl-TMn7HQxwSgarQ&_nc_ss=8&oh=00_AfyApiqdYReIHqHEIzqE39siDzUEG4EZKWVc38n51wiHkA&oe=69B2A350',
                      'https://scontent.fbkk3-1.fna.fbcdn.net/v/t39.30808-6/673302433_1647765037356574_5740877250400360971_n.jpg?stp=dst-jpg_p526x296_tt6&_nc_cat=108&ccb=1-7&_nc_sid=13d280&_nc_eui2=AeEMNjJCRBdVBf7xr9qJx6Xfc_HG0DJXVipz8cbQMldWKnjWzi1ot8cJwEhalMcj3oTcjXO4ptb4OWeIbWySNbeG&_nc_ohc=e9lQlDl4SfAQ7kNvwEtPevF&_nc_oc=Adru_QO43lkjEVGtxQder6GVwn0JFGrAQrkYLE8Gnqz65Zz_SFPj29ifMSqrO1IX6PU&_nc_zt=23&_nc_ht=scontent.fbkk3-1.fna&_nc_gid=hNL0_O4gb9fi2-c2Yy0lYA&_nc_ss=7b2a8&oh=00_Af2iXqWjN4edReR1D_lMUsuPJYspJBZ8n6_jgju9zQaHNw&oe=69F49CCE',
                  title: 'สถานที่ทำงานที่ไม่เคยขาดรอยยิ้ม เล่ม 1-3 วางจำหน่าย',
                  description:
                      'มังงะสายเฮฮาผสมความจริงจังของการทำงานวงการหนังสือการ์ตูน จำหน่ายโดย Dexpress',
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollablebook(
                  text: lp.translate('กำลังมาแรง', 'Trending'),
                  itemCount: trendingBooks,
                  width: 100,
                  separatorwidth: 15,
                ),
                Scrollablebook(
                  text: lp.translate('ฮิตติดท็อป', 'Top Hits'),
                  itemCount: topHitsBooks,
                  width: 100,
                  separatorwidth: 15,
                ),
                Scrollablebook(
                  text: lp.translate('มาใหม่', 'New Releases'),
                  itemCount: newBooks,
                  width: 100,
                  separatorwidth: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
