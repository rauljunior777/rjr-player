import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/helpers.dart';

Widget buildProgressBar({
  required VideoPlayerController controller,
  required VoidCallback onSeek,
}) {
  final pos = controller.value.position;
  final dur = controller.value.duration;

  return Column(
    children: [
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: Colors.cyanAccent,
          inactiveTrackColor: Colors.grey[700],
          thumbColor: Colors.cyan,
          overlayColor: Color.fromARGB(51, 0, 255, 255),
        ),
        child: Slider(
          min: 0,
          max: dur.inMilliseconds.toDouble(),
          value: pos.inMilliseconds.clamp(0, dur.inMilliseconds).toDouble(),
          onChanged: (value) {
            controller.seekTo(Duration(milliseconds: value.toInt()));
            onSeek();
          },
        ),
      ),
    ],
  );
}

Widget buildControlsLayout({
  required BoxConstraints constraints,
  required VideoPlayerController controller,
  required double playbackSpeed,
  required VoidCallback onTogglePlay,
  required Function(double) onSetSpeed,
  required VoidCallback onToggleFullscreen,
}) {
  final isWide = constraints.maxWidth > constraints.maxHeight;
  final pos = controller.value.position;
  final dur = controller.value.duration;

  final controles = [
    IconButton(
      icon: Icon(
        controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 30,
      ),
      onPressed: onTogglePlay,
    ),
    DropdownButton<double>(
      value: playbackSpeed,
      dropdownColor: Colors.grey[900],
      underline: SizedBox(),
      items: [0.25, 0.5, 1.0, 1.5, 2.0]
          .map(
            (speed) => DropdownMenuItem(
              value: speed,
              child: Text(
                '${speed}x',
                style: TextStyle(
                  color: playbackSpeed == speed
                      ? Colors.blueAccent
                      : Colors.white,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => onSetSpeed(value ?? 1.0),
    ),
    IconButton(
      onPressed: onToggleFullscreen,
      icon: Icon(
        controller.value.isPlaying ? Icons.fullscreen_exit : Icons.fullscreen,
      ),
      color: Colors.white,
    ),
  ];

  final tiempo = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(formatDuration(pos), style: TextStyle(color: Colors.white70)),
      SizedBox(width: 4),
      Text('/', style: TextStyle(color: Colors.white54)),
      SizedBox(width: 4),
      Text(formatDuration(dur), style: TextStyle(color: Colors.white70)),
    ],
  );

  final layout = isWide
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tiempo,
            const SizedBox(height: 6),
            ...controles.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: c,
              ),
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [...controles, tiempo],
        );

  return Transform.translate(offset: Offset(0, -20), child: layout);
}
