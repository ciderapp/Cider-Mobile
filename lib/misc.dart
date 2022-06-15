typedef AMAPICallback = Future<Map<String, dynamic>> Function(String, [Map<String, dynamic>?]);

enum MediaType {
  album,
  song,
  playlist,
}
