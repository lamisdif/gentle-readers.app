import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/animated_text.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _logoController;
  late AnimationController _loaderController;

  @override
  void initState() {
    super.initState();
    
    _textController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loaderController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController.forward().then((_) {
      _logoController.forward().then((_) {
        _loaderController.forward();
      });
    });
    
    // After 5 seconds, check if user is logged in
    Future.delayed(Duration(seconds: 5), () {
      final isLoggedIn = AuthService().isLoggedIn;
      
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _logoController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _textController,
              child: AnimatedText(),
            ),
            SizedBox(height: 30),
            FadeTransition(
              opacity: _logoController,
              child: Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 250,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.book, size: 80, color: Color(0xFF5e2217)),
              ),
            ),
            SizedBox(height: 25),
            FadeTransition(
              opacity: _loaderController,
              child: Lottie.asset(
                'assets/lottie/Book Loader.json',
                width: 140,
                height: 140,
                errorBuilder: (context, error, stack) => 
                    SpinKitThreeBounce(color: Color(0xFF5e2217), size: 30.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}