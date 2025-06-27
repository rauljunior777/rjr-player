import 'package:flutter/material.dart';
import 'package:rjr_player/screens/player_screen.dart';

void main() => runApp(VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RJR Player',
      theme: ThemeData.dark(),
      home: VideoPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
