import 'package:flutter/material.dart';
import 'package:rjr_player/screens/otra_ventana.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RJR Player',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const OtraVentana(),
    );
  }
}
