class BookModel {
  String id;
  String thumbnail;
  String title;
  List authors;
  int pageCount;
  String category;
  String description;
  String status;
  int isFavorite;
  String? note;
  String? noteImagePath;

  BookModel({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.authors,
    required this.pageCount,
    required this.category,
    required this.description,
    this.status = 'ยังไม่ได้อ่าน',
    this.isFavorite = 0,
    this.note,
    this.noteImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'authors': authors.join(', '),
      'pageCount': pageCount,
      'description': description,
      'category': category,
      'status': status,
      'isFavorite': isFavorite,
    };
  }

  factory BookModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return BookModel(
      thumbnail: json['thumbnail'] ?? '',
      id: documentId,
      title: json['title'] ?? '',
      authors: json['authors'] is String
          ? (json['authors'] as String).split(', ')
          : (json['authors'] as List?)?.map((e) => e.toString()).toList() ??
                ['ไม่มีข้อมูลผู้เขียน'],
      pageCount: json['pageCount'] ?? 0,
      category: json['category'] ?? 'ทั่วไป',
      description: json['description'] ?? '',
      status: json['status'] ?? 'ยังไม่ได้อ่าน',
      isFavorite: json['isFavorite'] ?? 0,
      note: json['note'],
      noteImagePath: json['noteImagePath'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'authors': authors.join(', '),
      'thumbnail': thumbnail,
      'pageCount': pageCount,
      'category': category,
      'description': description,
      'status': status,
      'isFavorite': isFavorite,
      'createdAt': DateTime.now(),
      'note': note,
      'noteImagePath': noteImagePath,
    };
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    final imageLinks = volumeInfo?['imageLinks'];
    final List<dynamic>? categoriesList = volumeInfo?['categories'];
    final String categoryName =
        (categoriesList != null && categoriesList.isNotEmpty)
        ? categoriesList[0].toString()
        : 'ทั่วไป';

    return BookModel(
      id: json['id'] ?? '',
      thumbnail: imageLinks != null
          ? imageLinks['thumbnail'].toString().replaceAll('http:', 'https:')
          : 'https://iarc-publications-website.s3.eu-west-3.amazonaws.com/media/default/0001/02/thumb_1291_default_publication.jpeg',
      title: volumeInfo['title'] ?? 'ไม่มีข้อมูลชื่อเรื่อง',
      authors:
          (volumeInfo?['authors'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['ไม่มีข้อมูลผู้เขียน'],
      pageCount: volumeInfo['pageCount'] ?? 0,
      description: volumeInfo['description'] ?? 'ไม่มีข้อมูลเนื้อเรื่องย่อ',
      category: categoryName,
      status: json['status'] ?? 'ยังไม่ได้อ่าน',
      isFavorite: json['isFavorite'] ?? 0,
    );
  }
  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      title: map['title'] ?? '',
      authors: (map['authors'] as String? ?? 'ไม่ระบุผู้เขียน').split(', '),
      pageCount: map['pageCount'] ?? 0,
      description: map['description'] ?? 'ไม่มีข้อมูลเนื้อเรื่องย่อ',
      category:
          (map['categories'] as List<dynamic>?)?.first.toString() ?? 'ทั่วไป',
      status: map['status'] ?? 'ยังไม่ได้อ่าน',
      isFavorite: map['isFavorite'] ?? 0,
    );
  }
}
