import 'dart:async';
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
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
    _currentPage = widget.startIndex;
    _loadController(_currentPage);
  }

  Future<VideoPlayerController> _loadController(int index) async {
    if (_controllers.containsKey(index)) return _controllers[index]!;

    final controller = VideoPlayerController.file(
      File(widget.playlist[index].path),
    );
    await controller.initialize();
    await controller.setPlaybackSpeed(_playbackSpeed);

    controller.addListener(() {
      final pos = controller.value.position;
      final dur = controller.value.duration;
      if (pos >= dur && !controller.value.isPlaying) {
        if (_currentPage < widget.playlist.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });

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
      for (var c in _controllers.values) {
        if (c.value.isInitialized) c.setPlaybackSpeed(speed);
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
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
              final isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;

              return GestureDetector(
                onTap: () {
                  setState(() => _showControls = !_showControls);
                  if (_showControls) _startHideTimer();
                },
                child: isLandscape
                    ? _buildLandscapeLayout(context, controller, index)
                    : _buildPortraitLayout(context, controller, index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    VideoPlayerController controller,
    int index,
  ) {
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
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(controller),
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () {
                            if (index > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
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
                            _startHideTimer();
                          },
                          color: Colors.white,
                          iconSize: 34,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: () {
                            if (index < widget.playlist.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<double>(
                          value: _playbackSpeed,
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(color: Colors.white70),
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
                        IconButton(
                          icon: const Icon(Icons.cast),
                          tooltip: 'Transmitir a TV',
                          onPressed: () {},
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    VideoPlayerController controller,
    int index,
  ) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  '${index + 1} / ${widget.playlist.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {
                        if (index > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
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
                        _startHideTimer();
                      },
                      color: Colors.white,
                      iconSize: 34,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        if (index < widget.playlist.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<double>(
                      value: _playbackSpeed,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white70),
                      underline: const SizedBox(),
                      onChanged: (value) => _setSpeed(value ?? _playbackSpeed),
                      items: [0.12, 0.25, 0.5, 1.0, 1.5, 2.0]
                          .map(
                            (speed) => DropdownMenuItem(
                              value: speed,
                              child: Text('${speed}x'),
                            ),
                          )
                          .toList(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cast),
                      tooltip: 'Transmitir a TV',
                      onPressed: () {
                        // Funcionalidad futura
                      },
                      color: Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
