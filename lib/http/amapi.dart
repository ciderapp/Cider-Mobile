import 'package:flutter/foundation.dart';

import 'json.dart';
export 'json.dart';

class AMException implements Exception {
  final String message;
  final int? statusCode;

  AMException(this.message, [this.statusCode]);

  @override
  String toString() {
    return 'AMException: $message';
  }
}

class AMError {
  final String? title;
  final String? detail;
  final String? code;

  AMError(this.title, this.detail, this.code);

  @override
  String toString() {
    return 'AMError: $title - $detail ($code)';
  }
}

class AMAPI {
  String _usrToken = "";
  String _devToken = "";

  String storefront = "";

  AMAPI._(String devToken, String usrToken) {
    _usrToken = usrToken;
    _devToken = devToken;

    if (_devToken.isEmpty) {
      throw Exception("Developer token is empty");
    }

    if (_usrToken.isEmpty) {
      throw Exception("User token is empty");
    }
  }

  static Future<AMAPI> create(String devToken, String usrToken) async {
    var amAPI = AMAPI._(devToken, usrToken);

    var sf = await amAPI.me("storefront");
    if (sf is List<AMError>) {
      throw AMException("Failed to get storefront", 500);
    }
    amAPI.storefront = sf[0]['id'];

    return amAPI;
  }

  // TODO: Wrapper around common API calls
  Future<dynamic> _generic(String endpoint, [JSON? query]) async {
    final headers = {
      'Authorization': 'Bearer $_devToken',
      'Music-User-Token': _usrToken,
      // fuck you apple
      'origin': 'https://beta.music.apple.com',
      'referer': 'https://beta.music.apple.com/',
    };
    final queryString = query?.entries.map((entry) {
      return '${entry.key}=${entry.value}';
    }).join('&');

    final uri = "https://api.music.apple.com/v1/$endpoint${queryString != null ? '?$queryString' : ''}";
    if (kDebugMode) print('amAPI: $uri');
    final res = await getJsonCache(uri, headers);

    if (res.statusCode != 200) {
      // OK so we got a HTTP error, let's see if we got any more info

      // TODO: More advanced error handling
      switch (res.statusCode) {
        case 400:
          throw AMException("Bad Request", res.statusCode);
        case 401:
          throw AMException("Unauthorized", res.statusCode);
        //case 403: // Returns an 'errors' array
        //  throw AMException("Forbidden", res.statusCode);
        case 404:
          throw AMException("Not found", res.statusCode);
        case 429:
          throw AMException("Rate Limited", res.statusCode);
        //case 500: // Returns an 'errors' array
        //  throw AMException("Internal Server Error", res.statusCode);
        default:
      }

      if (res.json.isEmpty) {
        // No response, throw exception
        throw AMException("Should've gotten a response, but didn't", res.statusCode);
      }

      // Apple should've given us an 'errors' array
      var errors = res.json['errors'] as List<dynamic>? ?? [];
      if (errors.isEmpty) {
        // No errors array, throw exception
        throw AMException("Should've gotten a response, but didn't", res.statusCode);
      }

      return errors.map((e) => AMError(e['title'], e['detail'], e['code']));
    }

    if (res.json['next'] != null) {
      if (kDebugMode) print('amAPI: next page ${res.json['next']}');
    }
    return (res.json['data'] as List<dynamic>).map((e) => e as JSON).toList(); // Should be fine with most endpoints
  }

  Future<dynamic> catalog(String endpoint, [JSON? query]) async {
    return await _generic("catalog/$storefront/$endpoint", query);
  }

  Future<dynamic> me(String endpoint, [JSON? query]) async {
    return await _generic("me/$endpoint", query);
  }
}
