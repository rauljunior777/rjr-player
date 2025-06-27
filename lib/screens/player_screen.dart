import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../widgets/player_controls.dart';
import '../overlays/top_panel.dart';
import '../overlays/bottom_panel.dart';
import '../utils/helpers.dart';
import 'otra_ventana.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  bool _isFullscreen = false;
  bool _isRotated = false;
  bool _showControls = true;
  bool _showTopPanel = false;
  bool _showStatusIcon = false;
  IconData _statusIcon = Icons.play_arrow;
  Timer? _hideTimer;
  final GlobalKey _videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(
            'https://www.w3schools.com/html/mov_bbb.mp4',
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
            _startHideTimer();
          });
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
                              color: Colors.white.withOpacity(0.9),
                              size: 100,
                            ),
                          ),
                        buildTopOverlay(
                          isVisible: _showTopPanel,
                          isRotated: _isRotated,
                          onRotate: _toggleRotation,
                          onOpenWindow: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OtraVentana()),
                            );
                          },
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
