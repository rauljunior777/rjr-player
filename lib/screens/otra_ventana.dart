import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'player_screen.dart';

class OtraVentana extends StatefulWidget {
  const OtraVentana({super.key});

  @override
  State<OtraVentana> createState() => _OtraVentanaState();
}

class _OtraVentanaState extends State<OtraVentana> {
  List<String> playlist = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        playlist = result.paths.whereType<String>().toList();
      });
    }
  }

  void _playVideo(int index) {
    Future.delayed(Duration(milliseconds: 50), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VideoPlayerScreen(playlist: playlist, initialIndex: index),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecciona tus videos')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickFiles,
            child: Text('Seleccionar videos'),
          ),
          Expanded(
            child: playlist.isEmpty
                ? Center(child: Text('No hay archivos seleccionados'))
                : ListView.builder(
                    itemCount: playlist.length,
                    itemBuilder: (context, index) {
                      final name = playlist[index].split('/').last;
                      return ListTile(
                        leading: Icon(Icons.movie),
                        title: Text(name),
                        trailing: IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () => _playVideo(index),
                        ),
                        onTap: () => _playVideo(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
