import 'package:flutter/material.dart';
import '../models/video_item.dart';

class FileTile extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onPlay;

  const FileTile({super.key, required this.video, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.movie, color: Colors.white70),
      title: Text(video.name, style: const TextStyle(color: Colors.white)),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.lightGreenAccent),
        onPressed: onPlay,
      ),
    );
  }
}
