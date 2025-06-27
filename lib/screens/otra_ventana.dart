import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class OtraVentana extends StatefulWidget {
  const OtraVentana({Key? key}) : super(key: key);

  @override
  _OtraVentanaState createState() => _OtraVentanaState();
}

class _OtraVentanaState extends State<OtraVentana> {
  List<PlatformFile> _selectedVideos = [];

  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null) {
      setState(() => _selectedVideos = result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar videos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideos,
        child: Icon(Icons.video_collection),
        tooltip: 'Seleccionar videos',
      ),
      body: _selectedVideos.isEmpty
          ? Center(child: Text('No has seleccionado ningún video'))
          : ListView.builder(
              itemCount: _selectedVideos.length,
              itemBuilder: (context, index) {
                final file = _selectedVideos[index];
                return ListTile(
                  leading: Icon(Icons.play_circle_fill, color: Colors.cyan),
                  title: Text(file.name),
                  subtitle: Text(
                    '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
                  ),
                  onTap: () {
                    // Aquí puedes reproducir el archivo con VideoPlayer o enviarlo a otra pantalla
                    print('Ruta: ${file.path}');
                  },
                );
              },
            ),
    );
  }
}
