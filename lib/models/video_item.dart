class VideoItem {
  final String path;
  final String name;

  VideoItem({required this.path}) : name = path.split('/').last;
}
