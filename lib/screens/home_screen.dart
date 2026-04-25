import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cart_model.dart';
import 'book_details_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import '../services/favourite_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Book> _allBooks = [];
  List<Book> _currentPageBooks = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _booksPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  List<Book> get _filteredBooks {
    if (_searchQuery.isEmpty) {
      return _currentPageBooks;
    }
    return _allBooks.where((book) {
      return book.title.toLowerCase().contains(_searchQuery) ||
          (book.title_en?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Future<void> _fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('https://gentle-readers.netlify.app/cms-books.json'),
      );
      if (response.statusCode == 200) {
        String jsonString = utf8.decode(response.bodyBytes);
        if (jsonString.startsWith('\ufeff')) {
          jsonString = jsonString.substring(1);
        }
        final List<dynamic> jsonList = json.decode(jsonString);
        setState(() {
          _allBooks = jsonList.map((j) => Book.fromJson(j)).toList();
          _totalPages = (_allBooks.length / _booksPerPage).ceil();
          _updatePage();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePage() {
    final start = (_currentPage - 1) * _booksPerPage;
    final end = start + _booksPerPage;
    setState(() {
      _currentPageBooks = _allBooks.sublist(
        start,
        end > _allBooks.length ? _allBooks.length : end,
      );
    });
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _updatePage();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showSearchDialog() {
    TextEditingController dialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Books', style: TextStyle(color: Color(0xFF5e2217))),
          content: TextField(
            controller: dialogController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter book name... / ابحث عن كتاب...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.search, color: Color(0xFF5e2217)),
            ),
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
                _searchController.text = value;
              });
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Color(0xFF5e2217))),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = dialogController.text.toLowerCase();
                  _searchController.text = dialogController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF5e2217)),
              child: Text('Search', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Color(0xFFf5f5dc),
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 100,
          title: _currentIndex == 0
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      'Gentle Readers',
                      style: TextStyle(
                        fontFamily: 'DancingScript',
                        fontSize: 28,
                        color: Color(0xFF5e2217),
                      ),
                    ),
                  ),
                )
              : Text(
                  _currentIndex == 1
                      ? 'Wishlist'
                      : _currentIndex == 2
                          ? 'Your Cart'
                          : 'Profile',
                  style: TextStyle(
                    color: Color(0xFF5e2217),
                    fontFamily: 'DancingScript',
                    fontSize: 24,
                  ),
                ),
          leading: _searchQuery.isNotEmpty && _currentIndex == 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF5e2217)),
                  onPressed: _clearSearch,
                  tooltip: 'Back to all books',
                )
              : null,
          actions: [
            if (_currentIndex == 0)
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Icon(Icons.search, color: Color(0xFF5e2217), size: 26),
                  onPressed: _showSearchDialog,
                ),
              ),
          ],
        ),
      ),
      body: _currentIndex == 0
          ? (_isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5e2217),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero Section
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/images/hero_image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                '📚 Your Next Great Read',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'DancingScript',
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Discover thousands of books at your fingertips',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF5e2217),
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Shop Now',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // All Books Section Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Books',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5e2217),
                              ),
                            ),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Page $_currentPage of $_totalPages'
                                  : '${_filteredBooks.length} results found',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      // Books Grid
                      BooksGridWidget(books: _filteredBooks),
                      // Pagination
                      if (_searchQuery.isEmpty && _totalPages > 1)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                                color: Color(0xFF5e2217),
                              ),
                              ...List.generate(
                                _totalPages > 5 ? 5 : _totalPages,
                                (index) {
                                  int pageNumber;
                                  if (_totalPages <= 5) {
                                    pageNumber = index + 1;
                                  } else if (_currentPage <= 3) {
                                    pageNumber = index + 1;
                                  } else if (_currentPage >= _totalPages - 2) {
                                    pageNumber = _totalPages - 4 + index;
                                  } else {
                                    pageNumber = _currentPage - 2 + index;
                                  }
                                  return GestureDetector(
                                    onTap: () => _goToPage(pageNumber),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _currentPage == pageNumber ? Color(0xFF5e2217) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Color(0xFF5e2217), width: 1),
                                      ),
                                      child: Text(
                                        '$pageNumber',
                                        style: TextStyle(
                                          color: _currentPage == pageNumber ? Colors.white : Color(0xFF5e2217),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
                                color: Color(0xFF5e2217),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ))
          : _currentIndex == 1
              ? WishlistScreen()
              : _currentIndex == 2
                  ? CartScreen()
                  : ProfileScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFf5f5dc),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index != 0) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
          selectedItemColor: Color(0xFF5e2217),
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFFf5f5dc),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class BooksGridWidget extends StatefulWidget {
  final List<Book> books;

  const BooksGridWidget({Key? key, required this.books}) : super(key: key);

  @override
  _BooksGridWidgetState createState() => _BooksGridWidgetState();
}

class _BooksGridWidgetState extends State<BooksGridWidget> {
  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final book = widget.books[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsScreen(book: book),
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    book.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Color(0xFFf5f5dc),
                      child: Icon(Icons.book,
                          size: 50, color: Color(0xFF5e2217).withOpacity(0.5)),
                    ),
                  ),
                ),
                // Book info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF5e2217),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Author
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        // Price
                        Text(
                          '${book.price} DA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF5e2217),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Favorite button row
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                book.isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () async {
                                final newStatus = await FavoriteService()
                                    .toggleFavorite(book.slug);
                                setState(() {
                                  book.isFavorited = newStatus;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Spacer(),
                          ],
                        ),
                        // Add to Cart button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: book.isAvailable
                                ? () {
                                    cart.addItem(book);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${book.title} added',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: const Color(0xFF5e2217),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: book.isAvailable
                                  ? const Color(0xFF5e2217)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(double.infinity, 32),
                            ),
                            child: Text(
                              book.isAvailable ? 'Add to Cart' : 'Out of Stock',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ConsumerCartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    if (cart.totalItems == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: Text(
        '${cart.totalItems}',
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}