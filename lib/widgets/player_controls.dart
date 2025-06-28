import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onTogglePlay;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 36,
            color: Colors.white,
          ),
          onPressed: onTogglePlay,
        ),
      ],
    );
  }
}
