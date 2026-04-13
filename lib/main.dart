import 'package:flutter/material.dart';
import 'models/cart_model.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_config.dart';
import 'services/music_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(MyApp());
    // Start background music after app loads
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CartProvider(
      notifier: CartModel(),
      child: MaterialApp(
        title: 'Gentle Readers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFf5f5dc),
          primaryColor: const Color(0xFF5e2217),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5e2217)),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFf5f5dc),
            foregroundColor: Color(0xFF5e2217),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'DancingScript',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5e2217),
            ),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}