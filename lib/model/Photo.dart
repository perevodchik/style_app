class Photo {
  String path;
  PhotoSource type;

  Photo(this.path, this.type);

  @override
  String toString() {
    return 'Photo{path: $path, source: $type}';
  }
}

enum PhotoSource {
  FILE,
  NETWORK
}
