import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../widgets/player_controls.dart';
import '../overlays/top_panel.dart';
import '../overlays/bottom_panel.dart';
import 'otra_ventana.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> playlist;
  final int initialIndex;

  const VideoPlayerScreen({
    Key? key,
    required this.playlist,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isControllerInitialized = false;
  double _playbackSpeed = 1.0;
  bool _isFullscreen = false;
  bool _isRotated = false;
  bool _showControls = true;
  bool _showTopPanel = false;
  bool _showStatusIcon = false;
  IconData _statusIcon = Icons.play_arrow;
  Timer? _hideTimer;
  final GlobalKey _videoKey = GlobalKey();

  late int _currentIndex;
  List<String> get playlist => widget.playlist;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadVideo(_currentIndex);
  }

  void _loadVideo(int index) async {
    final path = playlist[index];

    try {
      final file = File(path);
      if (!await file.exists()) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('El archivo no existe: $path')));
        return;
      }

      // Liberar controlador anterior si ya existe
      if (_controller.value.isInitialized) {
        await _controller.pause();
        await _controller.dispose();
      }

      _controller = VideoPlayerController.file(File(playlist[index]));

      await _controller.initialize();
      setState(() {
        _currentIndex = index;
        _isControllerInitialized = true;
      });
      _controller.play();
      _startHideTimer();

      _controller.addListener(() {
        final isAtEnd =
            _controller.value.position >= _controller.value.duration &&
            !_controller.value.isPlaying;

        if (isAtEnd) _playNext();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando video: $e')));
      print('[RJR] Error cargando video $path: $e');
    }
  }

  void _playNext() {
    if (_currentIndex + 1 < playlist.length) {
      _controller.dispose();
      _loadVideo(_currentIndex + 1);
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _controller.dispose();
      _loadVideo(_currentIndex - 1);
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
        _showTopPanel = false;
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _statusIcon = Icons.pause;
      } else {
        _controller.play();
        _statusIcon = Icons.play_arrow;
      }
      _showStatusIcon = true;
      _showControls = true;
    });

    _startHideTimer();

    Future.delayed(Duration(milliseconds: 700), () {
      setState(() => _showStatusIcon = false);
    });
  }

  void _setSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _controller.setPlaybackSpeed(speed);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    SystemChrome.setPreferredOrientations(
      _isFullscreen
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
    SystemChrome.setEnabledSystemUIMode(
      _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _toggleRotation() {
    setState(() => _isRotated = !_isRotated);
    SystemChrome.setPreferredOrientations(
      _isRotated
          ? [DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
  }

  double _getHalfVideoHeight() {
    final box = _videoKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.size.height / 2;
    }
    return MediaQuery.of(context).size.height * 0.25;
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(title: Text('Reproductor de Video')),
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = _getHalfVideoHeight();

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _showControls = !_showControls;
                        _showTopPanel = _showControls;
                      });
                      if (_showControls) _startHideTimer();
                    },
                    onDoubleTapDown: (details) {
                      final dx = details.localPosition.dx;
                      if (dx < width / 3) {
                        final back =
                            _controller.value.position - Duration(seconds: 10);
                        _controller.seekTo(
                          back > Duration.zero ? back : Duration.zero,
                        );
                      } else if (dx > 2 * width / 3) {
                        final fwd =
                            _controller.value.position + Duration(seconds: 10);
                        final max = _controller.value.duration;
                        _controller.seekTo(fwd < max ? fwd : max);
                      } else {
                        _togglePlayPause();
                      }
                      _startHideTimer();
                    },
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta != null &&
                          details.primaryDelta! > 10) {
                        setState(() => _showTopPanel = true);
                        _startHideTimer();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          key: _videoKey,
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        if (_showStatusIcon)
                          AnimatedOpacity(
                            opacity: _showStatusIcon ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 1500),
                            child: Icon(
                              _statusIcon,
                              color: Color.fromARGB(
                                230,
                                255,
                                255,
                                255,
                              ), // 0.9 * 255 = 229.5 ≈ 230
                              size: 100,
                            ),
                          ),
                        buildTopOverlay(
                          isVisible: _showTopPanel,
                          isRotated: _isRotated,
                          onRotate: _toggleRotation,
                          title: playlist[_currentIndex].split('/').last,
                          onOpenWindow: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OtraVentana()),
                            );
                          },
                          onPrevious: _playPrevious,
                          onNext: _playNext,
                          height: height,
                        ),
                        buildBottomOverlay(
                          isVisible: _showControls,
                          progressBar: buildProgressBar(
                            controller: _controller,
                            onSeek: _startHideTimer,
                          ),
                          controls: LayoutBuilder(
                            builder: (ctx, cons) {
                              return buildControlsLayout(
                                constraints: cons,
                                controller: _controller,
                                playbackSpeed: _playbackSpeed,
                                onTogglePlay: _togglePlayPause,
                                onSetSpeed: _setSpeed,
                                onToggleFullscreen: _toggleFullscreen,
                              );
                            },
                          ),
                          height: height,
                        ),
                      ],
                    ),
                  );
                },
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
