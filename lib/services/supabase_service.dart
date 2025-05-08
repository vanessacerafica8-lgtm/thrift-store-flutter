import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';

class SupabaseService extends ChangeNotifier {
  @override
  void notifyListeners() {
    if (hasListeners) super.notifyListeners();
  }

  final supabase = Supabase.instance.client;
  List<Item> items = [];
  String? error;

  // ─── AUTH ───────────────────────────────────────────────────
  Future<bool> signUp(String email, String password, String displayName) async {
    error = null;
    try {
      await supabase.auth.signUp(email: email, password: password);
      await supabase.auth.updateUser(
        UserAttributes(data: {'full_name': displayName}),
      );
      await supabase.auth.refreshSession();
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    error = null;
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ─── FETCH ALL ITEMS ─────────────────────────────────────────
  Future<void> fetchItems() async {
    try {
      final data = await supabase
          .from('items')
          .select()
          .order('created_at', ascending: false);
      items = (data as List)
          .map((e) => Item.fromMap(e as Map<String, dynamic>))
          .toList();
      error = null;
    } on PostgrestException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  // ─── ADD A NEW ITEM ───────────────────────────────────────────
  Future<void> addItem({
    required String title,
    required String desc,
    required double price,
    required String contact,
    required String uploaderName,
    required File image,
  }) async {
    try {
      // 1) upload image to storage
      final bucket = supabase.storage.from('thrift-images');
      final path = 'thrift/${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await bucket.uploadBinary(path, bytes);
      } else {
        await bucket.upload(path, image);
      }

      // 2) get the public URL
      final urlRes = bucket.getPublicUrl(path);
      final String url = bucket.getPublicUrl(path);

      // 3) insert the new item record
      final user = supabase.auth.currentUser;
      final email = user?.email ?? '';
      await supabase.from('items').insert({
        'title':          title,
        'description':    desc,
        'price':          price,
        'contact_info':   contact,
        'uploaded_by':    uploaderName,
        'uploader_email': email,
        'image_url':      url,
        'created_at':     DateTime.now().toIso8601String(),
      });

      // 4) refresh the list
      await fetchItems();
    } on StorageException catch (e) {
      error = e.message;
      notifyListeners();
    } on PostgrestException catch (e) {
      error = e.message;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ─── DELETE AN ITEM ──────────────────────────────────────────
  Future<void> deleteItem(int id) async {
    try {
      await supabase.from('items').delete().eq('id', id);
      await fetchItems();
    } on PostgrestException catch (e) {
      error = e.message;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ─── FETCH ONE ITEM DETAIL ───────────────────────────────────
  Future<Item?> fetchItemDetail(int id) async {
    try {
      final data = await supabase
          .from('items')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) throw PostgrestException(message: 'Item not found');
      return Item.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      error = e.message;
      return null;
    } catch (e) {
      error = e.toString();
      return null;
    }
  }
}
