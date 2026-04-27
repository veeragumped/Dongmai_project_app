import 'dart:io';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  //final FirebaseStorage _storage = FirebaseStorage.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

  Future<String> uploadNoteImage(File imageFile) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String path = 'note_images/$fileName';

      await _supabase.storage.from('notes').upload(path, imageFile);

      final String publicUrl = _supabase.storage
          .from('notes')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      return '';
    }
  }
}
