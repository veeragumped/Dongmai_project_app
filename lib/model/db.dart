import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/book_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    Directory appSupportDir = await getApplicationSupportDirectory();
    String path = join(appSupportDir.path, 'bookshelf.db');

    if (!await appSupportDir.exists()) {
      await appSupportDir.create(recursive: true);
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE shelf (
            id TEXT PRIMARY KEY,
            title TEXT,
            thumbnail TEXT,
            authors TEXT,
            pageCount INTEGER,
            description TEXT,
            category TEXT,
            status TEXT,
            isFavorite INTEGER DEFAULT 0,
            position INTEGER
          )
        ''');
        await db.execute('''
            CREATE TABLE wishlistshelf(
            id TEXT PRIMARY KEY,
            title TEXT,
            thumbnail TEXT,
            authors TEXT,
            pageCount INTEGER,
            description TEXT)''');

        await db.execute('''
            CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id TEXT UNIQUE, --
            content TEXT,
            image_path TEXT, 
            FOREIGN KEY (book_id) REFERENCES shelf (id) ON DELETE CASCADE)''');

        await db.execute('''
            CREATE TABLE challenge(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            goal_count INTEGER,
            current_count INTEGER,
            reward_points INTEGER,
            is_completed INTEGER DEFAULT 0)''');

        await db.execute('''
            CREATE TABLE challenge_books(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            challenge_id INTEGER,
            image_url TEXT)''');

        await db.execute('''
            CREATE TABLE user_stats(
            id INTEGER PRIMARY KEY,
            diamonds INTEGER DEFAULT 0)''');
        await db.insert('user_stats', {'id': 1, 'diamonds': 0});

        await db.execute('''
            CREATE TABLE shop_items(
            id INTEGER PRIMARY KEY,
            name TEXT,
            category TEXT,
            image_path TEXT,
            price INTEGER
            )''');

        await db.execute('''
            CREATE TABLE user_inventory(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT,
            category TEXT,
            item_img TEXT,
            is_equipped INTEGER DEFAULT 0)''');

        await db.execute('''
            CREATE TABLE shelf_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            position INTEGER UNIQUE,
            item_type TEXT,
            item_ref_id TEXT)''');
      },
    ); //สร้างตาราง
  }

  Future<void> addToShelf(BookModel book) async {
    final dbClient = await db;
    await dbClient.insert('shelf', {
      'id': book.id,
      'title': book.title,
      'thumbnail': book.thumbnail,
      'authors': book.authors.join(', '),
      'pageCount': book.pageCount,
      'description': book.description,
      'category': book.category,
      'status': book.status,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    var existingItem = await dbClient.query(
      'shelf_items',
      where: 'item_type = ? AND item_ref_id = ?',
      whereArgs: ['book', book.id],
    );

    if (existingItem.isEmpty) {
      var maxPosResult = await dbClient.rawQuery(
        'SELECT MAX(position) as maxPos FROM shelf_items',
      );
      int nextPos = (maxPosResult.first['maxPos'] as int? ?? -1) + 1;
      await dbClient.insert('shelf_items', {
        'position': nextPos,
        'item_type': 'book',
        'item_ref_id': book.id,
      });
    }
  }

  Future<void> addToWishlist(BookModel book) async {
    final dbClient = await db;
    await dbClient.insert('wishlistshelf', {
      'id': book.id,
      'title': book.title,
      'thumbnail': book.thumbnail,
      'authors': book.authors.join(', '),
      'pageCount': book.pageCount,
      'description': book.description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBook(String id) async {
    final dbClient = await db;
    await dbClient.delete('shelf', where: 'id=?', whereArgs: [id]);
    await dbClient.delete(
      'shelf_items',
      where: 'item_ref_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWishlistBook(String id) async {
    final dbClient = await db;
    await dbClient.delete('wishlistshelf', where: 'id=?', whereArgs: [id]);
  }

  Future<void> deleteNote(String bookID) async {
    final dbClient = await db;
    await dbClient.delete('notes', where: 'book_id = ?', whereArgs: [bookID]);
  }

  Future<void> updateBookStatus(String id, String newStatus) async {
    final dbClient = await db;
    await dbClient.update(
      'shelf',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateBooksOrder(List<BookModel> books) async {
    final dbClient = await db;
    Batch batch = dbClient.batch();

    for (int i = 0; i < books.length; i++) {
      batch.update(
        'shelf',
        {'position': i},
        where: 'id = ?',
        whereArgs: [books[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> saveNotes(
    String bookID,
    String content,
    String imagePaths,
  ) async {
    final dbClient = await db;
    await dbClient.insert('notes', {
      'book_id': bookID,
      'content': content,
      'image_path': imagePaths,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getNotes(String bookID) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'notes',
      where: 'book_id = ?',
      whereArgs: [bookID],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final dbClient = await db;
    return await dbClient.rawQuery('''
    SELECT 
    n.content, 
    n.book_id, 
    n.image_path, 
    s.title, 
    s.thumbnail,
    s.position
    FROM notes n
    JOIN shelf s ON n.book_id = s.id
    ORDER BY s.position ASC
  ''');
  }

  Future<List<BookModel>> getBooks() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'shelf',
      orderBy: 'position ASC',
    );

    return List.generate(maps.length, (i) {
      return BookModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        thumbnail: maps[i]['thumbnail'],
        authors: maps[i]['authors'] != null
            ? maps[i]['authors'].split(', ')
            : [],
        description: maps[i]['description'],
        pageCount: maps[i]['pageCount'],
        status: maps[i]['status'] ?? 'กำลังอ่าน',
        category: maps[i]['category'] ?? 'ทั่วไป',
        isFavorite: maps[i]['isFavorite'] ?? 0,
      );
    });
  }

  Future<BookModel?> getBookById(String id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'shelf',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BookModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> favorite(String id, int currentStatus) async {
    final dbClient = await db;
    int newStatus = (currentStatus == 1) ? 0 : 1;
    await dbClient.update(
      'shelf',
      {'isFavorite': newStatus},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<List<BookModel>> getFavoriteBooks() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'shelf',
      where: 'isFavorite=?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return BookModel(
        id: maps[i]['id'],
        thumbnail: maps[i]['thumbnail'],
        title: maps[i]['title'],
        authors: maps[i]['authors']?.split(',') ?? [],
        pageCount: maps[i]['pageCount'],
        description: maps[i]['description'],
        category: maps[i]['category'] ?? 'ทั่วไป',
        isFavorite: maps[i]['isFavorite'],
      );
    });
  }

  Future<List<BookModel>> getWishlistBooks() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'wishlistshelf',
    );

    return List.generate(maps.length, (i) {
      return BookModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        thumbnail: maps[i]['thumbnail'],
        authors: maps[i]['authors'] != null
            ? maps[i]['authors'].split(', ')
            : [],
        description: maps[i]['description'],
        pageCount: maps[i]['pageCount'],
        category: maps[i]['category'] ?? 'ทั่วไป',
        status: maps[i]['status'] ?? 'กำลังอ่าน',
      );
    });
  }

  Future<void> moveToShelf(BookModel book) async {
    final dbClient = await db;
    await dbClient.insert('shelf', {
      'id': book.id,
      'title': book.title,
      'thumbnail': book.thumbnail,
      'authors': book.authors.join(', '),
      'pageCount': book.pageCount,
      'description': book.description,
      'status': 'กำลังอ่าน',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await dbClient.delete('wishlistshelf', where: 'id=?', whereArgs: [book.id]);
  }

  Future<List<BookModel>> searchBooksInShelf(String query) async {
    final dbCilent = await db;
    final List<Map<String, dynamic>> maps = await dbCilent.query(
      'shelf',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return BookModel(
        id: maps[i]['id'],
        thumbnail: maps[i]['thumbnail'],
        title: maps[i]['title'],
        authors: maps[i]['authors'].toString().split(','),
        pageCount: maps[i]['pageCount'],
        description: maps[i]['description'],
        category: maps[i]['category'] ?? 'ทั่วไป',
      );
    });
  }

  Future<List<Map<String, dynamic>>> getChallenge() async {
    final dbClient = await db;
    return await dbClient.query('challenge');
  }

  Future<void> insertChallenge(Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.insert('challenge', data);
  }

  Future<int> updateChallengeProgress(
    int id,
    String title,
    int goal,
    int count,
  ) async {
    final dbClient = await db;
    return await dbClient.update(
      'challenge',
      {'title': title, 'goal_count': goal, 'current_count': count},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveChallengeProgress(
    int challengeid,
    List<String> images,
  ) async {
    final dbClient = await db;
    await dbClient.delete(
      'challenge_books',
      where: 'challenge_id = ?',
      whereArgs: [challengeid],
    );
    for (String url in images) {
      await dbClient.insert('challenge_books', {
        'challenge_id': challengeid,
        'image_url': url,
      });
    }
  }

  Future<List<String>> getChallengeBooks(int challengeid) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'challenge_books',
      where: 'challenge_id = ?',
      whereArgs: [challengeid],
    );
    return List.generate(maps.length, (i) => maps[i]['image_url'] as String);
  }

  Future<void> deleteChallenge(int id) async {
    final dbClient = await db;
    await dbClient.delete(
      'challenge_books',
      where: 'challenge_id = ?',
      whereArgs: [id],
    );
    await dbClient.delete('challenge', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getDiamonds() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('user_stats');

    if (maps.isNotEmpty) {
      int value = maps.first['diamonds'] ?? 0;

      return value;
    }

    return 0;
  }

  Future<void> addDiamonds(int amount) async {
    final dbClient = await db;
    int current = await getDiamonds();
    int newtotal = current + amount;
    await dbClient.insert('user_stats', {
      'id': 1,
      'diamonds': newtotal,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> spendDiamonds(
    String itemName,
    String category,
    String itemImg,
    int price,
  ) async {
    final dbClient = await db;
    int currentDiamonds = await getDiamonds();

    if (currentDiamonds >= price) {
      await dbClient.insert('user_stats', {
        'id': 1,
        'diamonds': currentDiamonds - price,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await dbClient.insert('user_inventory', {
        'item_name': itemName,
        'category': category,
        'item_img': itemImg,
        'is_equipped': 0,
      });
      return true;
    }
    return false;
  }

  Future<bool> checkOwned(String itemName) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'user_inventory',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
    return maps.isNotEmpty;
  }

  Future<void> equippedItem(
    String name,
    String imgPath,
    String category,
  ) async {
    final dbClient = await db;

    if (category == 'ชั้นหนังสือ') {
      await dbClient.update(
        'user_inventory',
        {'is_equipped': 0},
        where: 'category = ?',
        whereArgs: [category],
      );
    }
    await dbClient.update(
      'user_inventory',
      {'is_equipped': 1, 'item_img': imgPath},
      where: 'item_name = ?',
      whereArgs: [name],
    );
  }

  Future<Map<String, dynamic>?> getEquippedItem(String category) async {
    final dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(
      'user_inventory',
      where: 'category = ? AND is_equipped = 1',
      whereArgs: [category],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updateEquip(String name, bool status) async {
    final db = await this.db;
    await db.update(
      'user_inventory',
      {'is_equipped': status ? 1 : 0},
      where: 'item_name = ?',
      whereArgs: [name],
    );
  }

  Future<List<Map<String, dynamic>>> getShelfContent() async {
    final db = await this.db;
    return await db.rawQuery('''
      SELECT 
        si.position, 
        si.item_type,
        si.item_ref_id,
        CASE 
          WHEN si.item_type = 'book' THEN b.thumbnail 
          WHEN si.item_type = 'decoration' THEN ui.item_img 
        END AS display_img
      FROM shelf_items si
      LEFT JOIN shelf b ON si.item_ref_id = b.id AND si.item_type = 'book'
      LEFT JOIN user_inventory ui ON si.item_ref_id = ui.id AND si.item_type = 'decoration'
      ORDER BY si.position ASC
      ''');
  }

  Future<void> updateAllPositions(
    List<Map<String, dynamic>> reorderedList,
  ) async {
    final dbClient = await db;

    await dbClient.transaction((txn) async {
      await txn.delete('shelf_items');

      for (int i = 0; i < reorderedList.length; i++) {
        await txn.insert('shelf_items', {
          'position': i,
          'item_type': reorderedList[i]['item_type'],
          'item_ref_id': reorderedList[i]['item_ref_id'],
        });
      }
    });
  }

  Future<void> checkAndSyncBooks() async {
    final db = await this.db;
    var count = await db.rawQuery('SELECT COUNT(*) as count FROM shelf_items');

    if (count.first['count'] == 0) {
      var books = await db.query('books');
      Batch batch = db.batch();
      for (int i = 0; i < books.length; i++) {
        batch.insert('shelf_items', {
          'position': i,
          'item_type': 'book',
          'item_ref_id': books[i]['id'],
        });
      }
      await batch.commit();
    }
  }

  Future<void> syncInitialBooksToShelf() async {
    final db = await this.db;

    var countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM shelf_items',
    );
    int count = countResult.first['count'] as int;

    if (count == 0) {
      var books = await db.query('shelf');

      if (books.isNotEmpty) {
        Batch batch = db.batch();
        for (int i = 0; i < books.length; i++) {
          batch.insert('shelf_items', {
            'position': i,
            'item_type': 'book',
            'item_ref_id': books[i]['id'],
          });
        }
        await batch.commit(noResult: true);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getOwnedItems(String mode) async {
    final dbClient = await db;

    if (mode == 'all_deco') {
      return await dbClient.query(
        'user_inventory',
        where: 'category IN (?, ?)',
        whereArgs: ['ของตกแต่ง', 'ต้นไม้'],
      );
    }
    return await dbClient.query(
      'user_inventory',
      where: 'category = ?',
      whereArgs: [mode],
    );
  }

  Future<void> insertDecorationToShelf({
    required dynamic itemId,
    required int position,
  }) async {
    final dbClient = await db;
    await dbClient.insert('shelf_items', {
      'position': position,
      'item_type': 'decoration',
      'item_ref_id': itemId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromShelf(int position) async {
    final dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'shelf_items',
      columns: ['item_ref_id'],
      where: 'position = ?',
      whereArgs: [position],
    );
    if (result.isNotEmpty) {
      String itemId = result.first['item_ref_id'].toString();
      await dbClient.delete(
        'shelf_items',
        where: 'position = ?',
        whereArgs: [position],
      );
      await dbClient.delete(
        'user_inventory',
        where: 'id = ?',
        whereArgs: [itemId],
      );
    }
  }

  Future<String> getMostReadCategory() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> results = await dbClient.rawQuery(
      'SELECT category, COUNT(*) as count FROM shelf WHERE status = ? GROUP BY category ORDER BY count DESC LIMIT 1',
      ['อ่านจบแล้ว'],
    );
    if (results.isNotEmpty) {
      var category = results.first['category'];
      return category?.toString() ?? 'ทั่วไป';
    }
    return 'ทั่วไป';
  }

  Future<Map<String, Map<String, int>>> getStatusCategoryStats() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'shelf',
      columns: ['status', 'category'],
    );

    Map<String, Map<String, int>> stats = {
      'อ่านจบแล้ว': {},
      'ยังไม่ได้อ่าน': {},
    };

    for (var row in maps) {
      String status = row['status'] as String;
      String category = row['category'] as String? ?? 'ทั่วไป';

      if (stats.containsKey(status)) {
        stats[status]![category] = (stats[status]![category] ?? 0) + 1;
      }
    }
    return stats;
  }

  Future<int> countBooksByStatus(String status) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.rawQuery(
      'SELECT COUNT(*) as count FROM shelf WHERE status = ?',
      [status],
    );
    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }
}
