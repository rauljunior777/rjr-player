import 'package:flutter/material.dart';
import 'screens/selector_screen.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RJR Player',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const SelectorScreen(),
    );
  }
}
