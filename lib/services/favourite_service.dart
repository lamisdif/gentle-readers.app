import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  // Check if a book is favorited by current user
  Future<bool> isFavorited(String bookSlug) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return false;

    final response = await SupabaseConfig.client
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('book_slug', bookSlug);

    return response.isNotEmpty;
  }

  // Get all favorites for current user
  Future<List<String>> getFavorites() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return [];

    final response = await SupabaseConfig.client
        .from('favorites')
        .select('book_slug')
        .eq('user_id', user.id);

    return response.map((item) => item['book_slug'] as String).toList();
  }

  // Add a book to favorites
  Future<void> addFavorite(String bookSlug) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    await SupabaseConfig.client.from('favorites').insert({
      'user_id': user.id,
      'book_slug': bookSlug,
    });
  }

  // Remove a book from favorites
  Future<void> removeFavorite(String bookSlug) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    await SupabaseConfig.client
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('book_slug', bookSlug);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String bookSlug) async {
    final isFav = await isFavorited(bookSlug);
    if (isFav) {
      await removeFavorite(bookSlug);
      return false;
    } else {
      await addFavorite(bookSlug);
      return true;
    }
  }
}