import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Book Details',
          style: TextStyle(color: Color(0xFF5e2217)),
        ),
        backgroundColor: Color(0xFFf5f5dc),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF5e2217)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book image
            Container(
              height: 350,
              width: double.infinity,
              color: Color(0xFFf5f5dc),
              child: Image.network(
                book.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Container(
                  color: Color(0xFFf5f5dc),
                  child: Icon(Icons.book, size: 100, color: Color(0xFF5e2217).withOpacity(0.5)),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic title
                  Text(
                    book.title,
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5e2217),
                    ),
                  ),
                  // English title (if exists)
                  if (book.title_en != null && book.title_en!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        book.title_en!,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  SizedBox(height: 12),
                  
                  // Author
                  Text(
                    'by ${book.author}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Price
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF5e2217).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5e2217),
                          ),
                        ),
                        Text(
                          '${book.price} DA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5e2217),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Stock Status (bilingual)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: book.isAvailable 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          book.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: book.isAvailable ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          book.isAvailable ? 'متوفر / Available' : 'نفدت الكمية / Out of Stock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: book.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5e2217),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFf5f5dc),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      book.description.isNotEmpty 
                          ? book.description 
                          : 'No description available for this book.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: book.isAvailable ? () {
              CartProvider.of(context).addItem(book);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Color(0xFF5e2217),
                  content: Text(
                    '${book.title} added to cart!',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5e2217),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              book.isAvailable ? 'Add to Cart' : 'Out of Stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}