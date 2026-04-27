import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';
//import 'package:gongdong/model/db.dart';
import 'package:gongdong/style/app_style.dart';

class DecoPicker extends StatelessWidget {
  const DecoPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Appcolors.jetblackColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "เลือกของตกแต่งของคุณ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'supermarket',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: BookService().getOwnedItems('all_deco'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      "คุณยังไม่มีของตกแต่ง",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item['item_img'] ?? 'assets/images/allium.png',
                            fit: BoxFit.contain,
                          ),
                        ),
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
