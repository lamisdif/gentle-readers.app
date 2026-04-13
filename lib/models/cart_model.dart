import 'package:flutter/material.dart';

class Book {
  final String slug;
  final String title;
  final String? title_en;
  final String author;
  final double price;
  final String status;
  final String description;
  final String image;
  bool isFavorited;

  Book({
    required this.slug,
    required this.title,
    this.title_en,
    required this.author,
    required this.price,
    required this.status,
    required this.description,
    required this.image,
      this.isFavorited = false,
  });

   factory Book.fromJson(Map<String, dynamic> json) {
    // Handling relative image paths from your CMS
    String imageUrl = json['image'] ?? '';
    if (!imageUrl.startsWith('http')) {
      if (imageUrl.startsWith('/')) {
        imageUrl = 'https://gentle-readers.netlify.app$imageUrl';
      } else {
        imageUrl = 'https://gentle-readers.netlify.app/$imageUrl';
      }
    }

    return Book(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown',
      author: json['author']?.toString() ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'available',
      description: json['description']?.toString() ?? '',
      image: imageUrl,
      isFavorited: false,
    );
  }


  bool get isAvailable => status.toLowerCase() == 'available';
}

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice =>
      _items.fold(0, (total, item) => total + (item.book.price * item.quantity));

  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);

  void addItem(Book book) {
    // Check if book already in cart
    final index = _items.indexWhere((item) => item.book.slug == book.slug);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(book: book));
    }
    notifyListeners();
  }

  void removeItem(Book book) {
    _items.removeWhere((item) => item.book.slug == book.slug);
    notifyListeners();
  }

  void updateQuantity(Book book, int quantity) {
    if (quantity <= 0) {
      removeItem(book);
      return;
    }
    final index = _items.indexWhere((item) => item.book.slug == book.slug);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Built-in state management using InheritedNotifier
class CartProvider extends InheritedNotifier<CartModel> {
  const CartProvider({
    Key? key,
    required CartModel notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static CartModel of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartProvider>()!.notifier!;
  }
}
