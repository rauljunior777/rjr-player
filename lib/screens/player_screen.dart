import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatefulWidget {
  final List<VideoItem> playlist;
  final int startIndex;

  const PlayerScreen({super.key, required this.playlist, this.startIndex = 0});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final file = File(widget.playlist[_currentIndex].path);
    _controller = VideoPlayerController.file(file);
    await _controller.initialize();
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist[_currentIndex].name)),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          PlayerControls(
            controller: _controller,
            onTogglePlay: _togglePlayPause,
          ),
        ],
      ),
    );
  }
}
