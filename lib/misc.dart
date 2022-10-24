T? cast<T>(x) => x is T ? x : null;

enum MediaType {
  unknown,
  album,
  song,
  playlist,
  station,
}
