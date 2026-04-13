import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_model.dart';
import '../services/favourite_service.dart';
import 'book_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Book> _favoriteBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);

    try {
      // 1. Get favorite slugs from database
      final favoriteSlugs = await FavoriteService().getFavorites();

      if (favoriteSlugs.isEmpty) {
        setState(() {
          _favoriteBooks = [];
          _isLoading = false;
        });
        return;
      }

      // 2. Fetch all books from website
      final response = await http.get(
        Uri.parse('https://gentle-readers.netlify.app/cms-books.json'),
      );

      if (response.statusCode == 200) {
        String jsonString = utf8.decode(response.bodyBytes);
        if (jsonString.startsWith('\ufeff')) {
          jsonString = jsonString.substring(1);
        }
        final List<dynamic> jsonList = json.decode(jsonString);
        final allBooks = jsonList.map((j) => Book.fromJson(j)).toList();

        // 3. Filter only favorited books
        setState(() {
          _favoriteBooks = allBooks
              .where((book) => favoriteSlugs.contains(book.slug))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromWishlist(String bookSlug) async {
    await FavoriteService().removeFavorite(bookSlug);
    setState(() {
      _favoriteBooks.removeWhere((book) => book.slug == bookSlug);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Removed from wishlist'),
          duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f5dc),
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: TextStyle(
              color: Color(0xFF5e2217),
              fontFamily: 'DancingScript',
              fontSize: 24),
        ),
        backgroundColor: Color(0xFFf5f5dc),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF5e2217)))
          : _favoriteBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Your wishlist is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any book to add it',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _favoriteBooks.length,
                  itemBuilder: (context, index) {
                    final book = _favoriteBooks[index];
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsScreen(book: book),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    book.image,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 140,
                                      color: Color(0xFFf5f5dc),
                                      child: Icon(Icons.book, size: 50),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${book.price} DA',
                                        style: TextStyle(
                                            color: Color(0xFF5e2217),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: IconButton(
                              icon: Icon(Icons.favorite,
                                  color: Colors.red, size: 16),
                              onPressed: () => _removeFromWishlist(book.slug),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
