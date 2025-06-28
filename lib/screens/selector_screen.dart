import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/video_item.dart';
import 'swipe_player_screen.dart';
import '../widgets/file_tile.dart';

class SelectorScreen extends StatefulWidget {
  const SelectorScreen({super.key});

  @override
  State<SelectorScreen> createState() => _SelectorScreenState();
}

class _SelectorScreenState extends State<SelectorScreen> {
  List<VideoItem> playlist = [];

  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );
    if (result != null) {
      setState(() {
        playlist = result.paths
            .whereType<String>()
            .map((path) => VideoItem(path: path))
            .toList();
      });
    }
  }

  void _play(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SwipePlayerScreen(playlist: playlist, startIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tus videos')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickVideos,
            child: const Text('Seleccionar videos'),
          ),
          Expanded(
            child: playlist.isEmpty
                ? const Center(child: Text('No hay archivos seleccionados'))
                : ListView.builder(
                    itemCount: playlist.length,
                    itemBuilder: (context, index) {
                      return FileTile(
                        video: playlist[index],
                        onPlay: () => _play(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
