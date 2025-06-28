import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';

class SwipePlayerScreen extends StatefulWidget {
  final List<VideoItem> playlist;
  final int startIndex;

  const SwipePlayerScreen({
    super.key,
    required this.playlist,
    this.startIndex = 0,
  });

  @override
  State<SwipePlayerScreen> createState() => _SwipePlayerScreenState();
}

class _SwipePlayerScreenState extends State<SwipePlayerScreen> {
  late PageController _pageController;
  final Map<int, VideoPlayerController> _controllers = {};
  double _playbackSpeed = 1.0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
    _currentPage = widget.startIndex;
    _loadController(_currentPage); // precarga inicial
  }

  Future<VideoPlayerController> _loadController(int index) async {
    if (_controllers.containsKey(index)) return _controllers[index]!;

    final file = File(widget.playlist[index].path);
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    await controller.setPlaybackSpeed(_playbackSpeed);
    _controllers[index] = controller;
    return controller;
  }

  void _cleanupControllers(int keepIndex) {
    final keysToRemove = _controllers.keys
        .where((key) => (key - keepIndex).abs() > 1)
        .toList();

    for (var index in keysToRemove) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }
  }

  void _setSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      for (var controller in _controllers.values) {
        if (controller.value.isInitialized) {
          controller.setPlaybackSpeed(speed);
        }
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.playlist.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          _cleanupControllers(index);
        },
        itemBuilder: (context, index) {
          return FutureBuilder<VideoPlayerController>(
            future: _loadController(index),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final controller = snapshot.data!;
              final title = widget.playlist[index].name;

              return Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    '${index + 1} / ${widget.playlist.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () {
                          if (index > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            controller.value.isPlaying
                                ? controller.pause()
                                : controller.play();
                          });
                        },
                        color: Colors.white,
                        iconSize: 34,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: () {
                          if (index < widget.playlist.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<double>(
                        value: _playbackSpeed,
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(color: Colors.white),
                        underline: const SizedBox(),
                        onChanged: (value) =>
                            _setSpeed(value ?? _playbackSpeed),
                        items: [0.12, 0.25, 0.5, 1.0, 1.5, 2.0]
                            .map(
                              (speed) => DropdownMenuItem(
                                value: speed,
                                child: Text('${speed}x'),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
