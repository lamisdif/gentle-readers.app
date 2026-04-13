import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String fullText = "Welcome To Gentle Readers";
  String displayedText = "";

  @override
  void initState() {
    super.initState();
    startTyping();
  }

  void startTyping() async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 80));
      if (mounted) {
        setState(() {
          displayedText = fullText.substring(0, i + 1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: TextStyle(
        fontFamily: 'DancingScript',
        fontSize: 28,
        color: Color(0xFF5e2217),
      ),
      textAlign: TextAlign.center,
    );
  }
}