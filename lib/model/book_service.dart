import 'dart:convert';
import 'dart:io';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:gongdong/model/book_model.dart';
//import 'package:gongdong/model/db.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  final _supabase = Supabase.instance.client;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? "guest_user";
  final List<String> noSearchWords = ['นิตยสาร', 'มติชน', 'ข่าว'];

  Future<List<BookModel>> fetchBooks(String query) async {
    final r = RetryOptions(
      maxAttempts: 5,
      delayFactor: const Duration(seconds: 1),
    );

    final apiKey = dotenv.env['API_KEY'];

    try {
      return await r.retry(() async {
        final response = await http
            .get(
              Uri.parse(
                'https://www.googleapis.com/books/v1/volumes?q=$query&printType=books&langRestrict=th&orderBy=newest&key=$apiKey',
              ),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode != 200) {
          //print('API Error: ${response.statusCode}');
          throw Exception('StatusCode: ${response.statusCode}');
        }

        final data = json.decode(response.body);
        if (data['items'] == null) return [];

        return (data['items'] as List)
            .map((i) => BookModel.fromJson(i))
            .toList();
      });
    } catch (e) {
      //print('🚨 Fetch Error: $e');
      return [];
    }
  }

  // Firestore
  // --- Shelf & Books ---
  Future<void> addToShelf(BookModel book) async {
    Map<String, dynamic> bookData = book.toFirestore();
    bookData['search_title'] = book.title.toLowerCase();

    await _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(book.id)
        .set(bookData);

    var existingItem = await _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items')
        .where('item_type', isEqualTo: 'book')
        .where('item_ref_id', isEqualTo: book.id)
        .get();

    if (existingItem.docs.isEmpty) {
      var maxPosResult = await _db
          .collection('users')
          .doc(uid)
          .collection('shelf_items')
          .orderBy('position', descending: true)
          .limit(1)
          .get();

      int nextPos = 0;
      if (maxPosResult.docs.isNotEmpty) {
        nextPos = (maxPosResult.docs.first.data()['position'] as int) + 1;
      }

      await _db.collection('users').doc(uid).collection('shelf_items').add({
        'position': nextPos,
        'item_type': 'book',
        'item_ref_id': book.id,
      });
    }
  }

  Future<void> deleteBook(String id) async {
    if (id.isEmpty) return;
    await _db.collection('users').doc(uid).collection('books').doc(id).delete();

    var shelfItems = await _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items')
        .where('item_ref_id', isEqualTo: id)
        .get();

    for (var doc in shelfItems.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateBookStatus(String id, String newStatus) async {
    await _db.collection('users').doc(uid).collection('books').doc(id).update({
      'status': newStatus,
    });
  }

  Future<void> removeFromShelfById(String shelfDocId, String bookId) async {
    final batch = _db.batch();

    final shelfItemRef = _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items')
        .doc(shelfDocId);
    batch.delete(shelfItemRef);

    final bookRef = _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(bookId);
    batch.delete(bookRef);

    await batch.commit();
  }

  Future<void> updateBooksOrder(List<BookModel> books) async {
    WriteBatch batch = _db.batch();

    for (int i = 0; i < books.length; i++) {
      DocumentReference bookRef = _db
          .collection('users')
          .doc(uid)
          .collection('books')
          .doc(books[i].id);
      batch.update(bookRef, {'position': i});
    }

    await batch.commit();
  }

  Future<void> updateAllPositions(
    List<Map<String, dynamic>> reorderedList,
  ) async {
    WriteBatch batch = _db.batch();
    final collectionRef = _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items');

    final snapshots = await collectionRef.get();

    Map<String, DocumentReference> docRefs = {
      for (var doc in snapshots.docs) doc.data()['item_ref_id']: doc.reference,
    };

    for (int i = 0; i < reorderedList.length; i++) {
      final refId = reorderedList[i]['item_ref_id'];
      if (docRefs.containsKey(refId)) {
        batch.update(docRefs[refId]!, {'position': i});
      }
    }

    await batch.commit();
  }

  Stream<List<BookModel>> getBooksFromShelf() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items')
        .where('item_type', isEqualTo: 'book')
        .snapshots()
        .asyncMap((snapshot) async {
          List<BookModel> books = [];

          for (var doc in snapshot.docs) {
            String bookId = doc.data()['item_ref_id'];

            var bookDoc = await _db
                .collection('users')
                .doc(uid)
                .collection('books')
                .doc(bookId)
                .get();

            if (bookDoc.exists) {
              books.add(BookModel.fromMap(bookDoc.data()!));
            }
          }
          return books;
        });
  }

  Stream<List<BookModel>> getBooks() {
    return _db.collection('users').doc(uid).collection('books').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return BookModel(
            id: doc.id,
            title: data['title'] ?? '',
            thumbnail: data['thumbnail'] ?? '',
            authors: data['authors'] != null
                ? data['authors'].toString().split(', ')
                : [],
            description: data['description'] ?? '',
            pageCount: data['pageCount'] ?? 0,
            status: data['status'] ?? 'กำลังอ่าน',
            category: data['category'] ?? 'ทั่วไป',
            isFavorite: data['isFavorite'] ?? 0,
          );
        }).toList();
      },
    );
  }

  Stream<BookModel?> getBookById(String id) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(id)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            return BookModel(
              id: doc.id,
              title: data['title'] ?? '',
              thumbnail: data['thumbnail'] ?? '',
              authors: data['authors'] != null
                  ? data['authors'].toString().split(', ')
                  : [],
              description: data['description'] ?? '',
              pageCount: data['pageCount'] ?? 0,
              status: data['status'] ?? 'กำลังอ่าน',
              category: data['category'] ?? 'ทั่วไป',
              isFavorite: data['isFavorite'] ?? 0,
            );
          }
          return null;
        });
  }

  Future<void> favorite(String bookId, int isFavorite) async {
    final docRef = _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(bookId);
    final favRef = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(bookId);
    if (isFavorite == 1) {
      await docRef.update({'isFavorite': 0});
      await favRef.delete();
    } else {
      await docRef.update({'isFavorite': 1});

      final bookDoc = await docRef.get();
      if (bookDoc.exists) {
        await favRef.set(bookDoc.data()!);
      }
    }
  }

  Stream<List<BookModel>> getFavoriteBooks() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .where('isFavorite', isEqualTo: 1)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return BookModel(
              id: doc.id,
              thumbnail: data['thumbnail'],
              title: data['title'],
              authors: data['authors'] != null
                  ? data['authors'].toString().split(',')
                  : [],
              pageCount: data['pageCount'],
              description: data['description'],
              category: data['category'] ?? 'ทั่วไป',
              isFavorite: data['isFavorite'] ?? 0,
            );
          }).toList();
        });
  }

  Future<void> checkAndSyncBooks() async {
    final shelfItemsRef = _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items');
    final shelfItemsSnapshot = await shelfItemsRef.limit(1).get();

    if (shelfItemsSnapshot.docs.isEmpty) {
      final booksSnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('books')
          .get();
      if (booksSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _db.batch();
        for (int i = 0; i < booksSnapshot.docs.length; i++) {
          batch.set(shelfItemsRef.doc(), {
            'position': i,
            'item_type': 'book',
            'item_ref_id': booksSnapshot.docs[i].id,
          });
        }
        await batch.commit();
      }
    }
  }

  // --- Wishlist ---
  Future<void> addToWishlist(BookModel book) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(book.id)
        .set({
          'id': book.id,
          'title': book.title,
          'thumbnail': book.thumbnail,
          'authors': book.authors.join(', '),
          'pageCount': book.pageCount,
          'description': book.description,
        });
  }

  Future<void> deleteWishlistBook(String id) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(id)
        .delete();
  }

  Stream<List<BookModel>> getWishlistBooks() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return BookModel(
              id: doc.id,
              title: data['title'] ?? '',
              thumbnail: data['thumbnail'],
              authors: data['authors'] != null
                  ? data['authors'].toString().split(', ')
                  : [],
              description: data['description'],
              pageCount: data['pageCount'],
              category: data['category'] ?? 'ทั่วไป',
              status: data['status'] ?? 'กำลังอ่าน',
            );
          }).toList();
        });
  }

  Future<void> moveToShelf(BookModel book) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(book.id)
        .set(book.toFirestore());
    var existingItem = await _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items')
        .where('item_type', isEqualTo: 'book')
        .where('item_ref_id', isEqualTo: book.id)
        .get();
    if (existingItem.docs.isEmpty) {
      var maxPosResult = await _db
          .collection('users')
          .doc(uid)
          .collection('shelf_items')
          .orderBy('position', descending: true)
          .limit(1)
          .get();
      int nextPos = 0;
      if (maxPosResult.docs.isNotEmpty) {
        nextPos = (maxPosResult.docs.first.data()['position'] as int) + 1;
      }
      await _db.collection('users').doc(uid).collection('shelf_items').add({
        'position': nextPos,
        'item_type': 'book',
        'item_ref_id': book.id,
      });
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(book.id)
        .delete();
  }

  // --- Notes ---
  Future<void> saveNotes(
    String bookID,
    String content,
    String imagePaths,
  ) async {
    await _db.collection('users').doc(uid).collection('notes').doc(bookID).set({
      'book_id': bookID,
      'content': content,
      'image_path': imagePaths,
    });
  }

  Future<void> deleteNote(String bookID) async {
    var notes = await _db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .where('book_id', isEqualTo: bookID)
        .get();

    for (var doc in notes.docs) {
      await doc.reference.delete();
    }
  }

  Future<Map<String, dynamic>?> getNotes(String bookID) async {
    var doc = await _db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(bookID)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>> getAllNotes() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .snapshots()
        .asyncMap((notesSnapshot) async {
          final booksSnapshot = await _db
              .collection('users')
              .doc(uid)
              .collection('books')
              .get();

          final booksMap = {
            for (var doc in booksSnapshot.docs) doc.id: doc.data(),
          };

          final results = notesSnapshot.docs
              .map((noteDoc) {
                final noteData = noteDoc.data();
                final bookId = noteData['book_id'];
                final bookData = booksMap[bookId];

                if (bookData == null) return null;

                return {
                  'content': noteData['content'],
                  'book_id': bookId,
                  'image_path': noteData['image_path'],
                  'title': bookData['title'],
                  'thumbnail': bookData['thumbnail'],
                  'position': bookData['position'] ?? 0,
                };
              })
              .whereType<Map<String, dynamic>>()
              .toList();

          results.sort(
            (a, b) => (a['position'] as int).compareTo(b['position'] as int),
          );

          return results;
        });
  }

  // --- Diamonds & Currency ---
  Stream<int> getDiamonds() {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data()?['diamonds'] as int? ?? 0;
      }
      return 0;
    });
  }

  Future<void> addDiamonds(int amount) async {
    await _db.collection('users').doc(uid).set({
      'diamonds': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }

  Future<bool> spendDiamonds(
    String itemName,
    String category,
    String itemImg,
    int price,
  ) async {
    final userRef = _db.collection('users').doc(uid);

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return false;

      int currentDiamonds = snapshot.get('diamonds') ?? 0;

      if (currentDiamonds >= price) {
        transaction.update(userRef, {'diamonds': currentDiamonds - price});

        DocumentReference inventoryRef = userRef.collection('inventory').doc();
        transaction.set(inventoryRef, {
          'item_name': itemName,
          'category': category,
          'item_img': itemImg,
          'is_equipped': 0,
        });

        return true;
      }
      return false;
    });
  }

  // --- Challenges ---
  Stream<List<Map<String, dynamic>>> getChallenge() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('challenges')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {...data, 'id': doc.id};
          }).toList();
        });
  }

  Future<String> getEquippedShelfImage() async {
    var doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['equippedShelfImage'] ?? 'assets/images/shelfbg.png';
  }

  Future<void> insertChallenge(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('challenges').add(data);
  }

  Future<void> updateChallengeProgress(
    String id,
    String title,
    int goal,
    int count,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('challenges')
        .doc(id)
        .update({'title': title, 'goal_count': goal, 'current_count': count});
  }

  Future<void> saveChallengeProgress(
    String challengeid,
    List<String> images,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('challenges')
        .doc(challengeid)
        .update({'images': images});
  }

  Stream<List<String>> getChallengeBooks(String challengeid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('challenges')
        .doc(challengeid)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            return List<String>.from(data['images'] ?? []);
          }
          return [];
        });
  }

  Future<void> claimChallengeReward(String challengeId, int goalCount) async {
    final userRef = _db.collection('users').doc(uid);
    final challengeRef = userRef.collection('challenges').doc(challengeId);

    int totalReward = goalCount * 10;

    try {
      await _db.runTransaction((transaction) async {
        DocumentSnapshot userSnap = await transaction.get(userRef);
        if (!userSnap.exists) return;

        int currentDiamonds = 0;
        final userData = userSnap.data() as Map<String, dynamic>;
        if (userData.containsKey('diamonds')) {
          currentDiamonds = userData['diamonds'] as int;
        }

        transaction.update(userRef, {
          'diamonds': currentDiamonds + totalReward,
        });

        transaction.delete(challengeRef);
      });
    } catch (e) {
      throw Exception("ไม่สามารถรับรางวัลได้");
    }
  }

  Future<void> deleteChallenge(String id) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('challenges')
        .doc(id)
        .delete();
  }

  // --- Decorations & Inventory ---
  Stream<bool> checkOwned(String itemName) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .where('item_name', isEqualTo: itemName)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> updateEquip(String name, bool status) async {
    final querySnapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .where('item_name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'is_equipped': status ? 1 : 0,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getShelfContent() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('shelf_items')
        .orderBy('position')
        .snapshots()
        .asyncMap((snapshot) async {
          final booksSnapshot = await _db
              .collection('users')
              .doc(uid)
              .collection('books')
              .get();

          final inventorySnapshot = await _db
              .collection('users')
              .doc(uid)
              .collection('inventory')
              .get();

          final booksMap = {
            for (var doc in booksSnapshot.docs) doc.id: doc.data(),
          };
          final inventoryMap = {
            for (var doc in inventorySnapshot.docs) doc.id: doc.data(),
          };

          return snapshot.docs.map((itemDoc) {
            final itemData = itemDoc.data();
            final type = itemData['item_type'];
            final refId = itemData['item_ref_id'].toString();
            String displayImg = '';

            if (type == 'book') {
              displayImg = booksMap[refId]?['thumbnail'] ?? '';
            } else if (type == 'decoration') {
              displayImg =
                  inventoryMap[refId]?['item_img'] ??
                  inventoryMap[refId]?['display_img'] ??
                  '';
            }

            return {
              'id': itemDoc.id,
              'position': itemData['position'] ?? 0,
              'item_type': type ?? 'unknown',
              'item_ref_id': refId,
              'display_img': displayImg,
            };
          }).toList();
        });
  }

  Stream<Map<String, dynamic>?> getEquippedItem(String category) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .where('category', isEqualTo: category)
        .where('is_equipped', isEqualTo: 1)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.data();
          }
          return null;
        });
  }

  Future<void> equippedItem(
    String name,
    String imgPath,
    String category,
  ) async {
    WriteBatch batch = _db.batch();
    final inventoryRef = _db
        .collection('users')
        .doc(uid)
        .collection('inventory');

    if (category == 'ชั้นหนังสือ') {
      final equippedItems = await inventoryRef
          .where('category', isEqualTo: category)
          .where('is_equipped', isEqualTo: 1)
          .get();

      for (var doc in equippedItems.docs) {
        batch.update(doc.reference, {'is_equipped': 0});
      }
    }

    final itemQuery = await inventoryRef
        .where('item_name', isEqualTo: name)
        .limit(1)
        .get();

    if (itemQuery.docs.isNotEmpty) {
      batch.update(itemQuery.docs.first.reference, {
        'is_equipped': 1,
        'item_img': imgPath,
      });
    }

    await batch.commit();
  }

  Future<void> insertDecorationToShelf({
    required dynamic itemId,
    required int position,
  }) async {
    final inventoryDoc = await _db
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .doc(itemId.toString())
        .get();

    String displayImg = '';
    if (inventoryDoc.exists) {
      displayImg = inventoryDoc.data()?['display_img'] ?? '';
    }

    await _db.collection('users').doc(uid).collection('shelf_items').add({
      'position': position,
      'item_type': 'decoration',
      'item_ref_id': itemId,
      'display_img': displayImg,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getOwnedItems(String mode) {
    Query query = _db.collection('users').doc(uid).collection('inventory');

    if (mode == 'all_deco') {
      query = query.where('category', whereIn: ['ของตกแต่ง', 'ต้นไม้']);
    } else {
      query = query.where('category', isEqualTo: mode);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    });
  }

  // --- Statistics & Search ---
  Future<Map<String, Map<String, int>>> getStatusCategoryStats() async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .get();

    Map<String, Map<String, int>> stats = {
      'อ่านจบแล้ว': {},
      'ยังไม่ได้อ่าน': {},
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String status = data['status'] ?? '';
      String category = data['category'] ?? 'ทั่วไป';

      if (stats.containsKey(status)) {
        stats[status]![category] = (stats[status]![category] ?? 0) + 1;
      }
    }
    return stats;
  }

  Future<String> getMostReadCategory() async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .where('status', isEqualTo: 'อ่านจบแล้ว')
        .get();

    if (snapshot.docs.isEmpty) {
      return 'ทั่วไป';
    }

    Map<String, int> categoryCounts = {};

    for (var doc in snapshot.docs) {
      String category = doc.data()['category'] ?? 'ทั่วไป';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    var sortedEntries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.first.key;
  }

  Future<int> countBooksByStatus(String status) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .where('status', isEqualTo: status)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Stream<List<BookModel>> searchBooksInShelf(String query) {
    final lowercaseQuery = query.toLowerCase();

    return _db
        .collection('users')
        .doc(uid)
        .collection('books')
        .where('search_title', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('search_title', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return BookModel(
              id: doc.id,
              thumbnail: data['thumbnail'] ?? '',
              title: data['title'] ?? '',
              authors: data['authors'] != null
                  ? (data['authors'] is List
                        ? List<String>.from(data['authors'])
                        : data['authors'].toString().split(','))
                  : [],
              pageCount: data['pageCount'] ?? 0,
              description: data['description'] ?? '',
              category: data['category'] ?? 'ทั่วไป',
            );
          }).toList();
        });
  }

  // --- Account ---
  Future<void> updateUsername(String newName) async {
    await _db.collection('users').doc(uid).update({'username': newName});
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final fileName = '$uid.jpg';
      await _supabase.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    await _db.collection('users').doc(uid).update({'profileImage': imageUrl});
  }

  //Setting
  static Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('fontSize') ?? 1.0;
  }

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'ไทย';
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
