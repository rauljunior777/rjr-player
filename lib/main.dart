import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

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

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  bool _isFullscreen = false;
  bool _showControls = true;
  bool _showTopPanel = false;
  bool _isRotated = false;
  bool _showStatusIcon = false;
  Timer? _hideTimer;
  IconData _statusIcon = Icons.play_arrow;

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

  void _toggleRotation() {
    setState(() => _isRotated = !_isRotated);
    SystemChrome.setPreferredOrientations(
      _isRotated
          ? [DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
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
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            axisAlignment: 1.0,
            child: child,
          );
        },
        child: _showTopPanel
            ? Container(
                key: ValueKey(true),
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.only(top: 12.0, bottom: 9.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isRotated
                            ? Icons.screen_lock_rotation
                            : Icons.screen_rotation,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        _toggleRotation();
                        _startHideTimer();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.open_in_new),
                      color: Colors.white,
                      onPressed: () {
                        _startHideTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OtraVentana()),
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );
  }

  Widget _buildProgressBar() {
    final Duration position = _controller.value.position;
    final Duration duration = _controller.value.duration;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.cyanAccent,
            inactiveTrackColor: Colors.grey[700],
            thumbColor: Colors.cyan,
            overlayColor: Colors.cyan.withOpacity(0.2),
          ),
          child: Slider(
            min: 0,
            max: duration.inMilliseconds.toDouble(),
            value: position.inMilliseconds
                .clamp(0, duration.inMilliseconds)
                .toDouble(),
            onChanged: (value) {
              _controller.seekTo(Duration(milliseconds: value.toInt()));
              _startHideTimer(); // Oculta controles tras cambiar
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 30,
      ),
      onPressed: _togglePlayPause,
    );
  }

  Widget _buildSizeScreenButton() {
    return IconButton(
      onPressed: _toggleFullscreen,
      icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
    );
  }

  Widget _buildSpeedDropdown() {
    final speeds = [0.12, 0.25, 0.5, 1.0, 1.5, 2.0];
    return DropdownButton<double>(
      value: _playbackSpeed,
      dropdownColor: Colors.grey[900],
      underline: SizedBox(),
      items: speeds
          .map(
            (speed) => DropdownMenuItem<double>(
              value: speed,
              child: Text(
                '${speed}x',
                style: TextStyle(
                  color: _playbackSpeed == speed
                      ? Colors.blueAccent
                      : Colors.white,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) _setSpeed(value);
      },
    );
  }

  Widget _buildControlsLayout(BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > constraints.maxHeight;
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    final controles = [
      _buildPlayPauseButton(),
      _buildSpeedDropdown(),
      _buildSizeScreenButton(),
    ];

    final tiempo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDuration(position),
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(width: 8),
        Text('/', style: TextStyle(color: Colors.white54)),
        const SizedBox(width: 8),
        Text(
          _formatDuration(duration),
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );

    return isWide
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tiempo,
              const SizedBox(height: 6),
              ...controles.map(
                (control) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: control,
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [...controles, tiempo],
          );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            axisAlignment: -1.0,
            child: child,
          );
        },
        child: _showControls
            ? Container(
                key: ValueKey(true),
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: _buildProgressBar(),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Transform.translate(
                          offset: Offset(0, -25),
                          child: _buildControlsLayout(constraints),
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen ? null : AppBar(title: Text('RJR Player')),
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

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
                        // Deslizó hacia abajo
                        setState(() => _showTopPanel = true);
                        _startHideTimer();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
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
                        _buildTopOverlay(),
                        _buildControlsOverlay(),
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

class OtraVentana extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Otra ventana')),
      body: Center(
        child: Text(
          '¡Hola desde otra ventana!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
