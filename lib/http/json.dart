import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

typedef JSON = Map<String, dynamic>;
typedef JSONList = List<JSON>;

class JSONResponse {
  final JSON json;
  final int statusCode;

  JSONResponse(String? body, this.statusCode) : json = body != null ? jsonDecode(body) : {};
}

Future<JSONResponse> getJson(String uri, dynamic headers) async {
  var url = Uri.parse(uri);
  final response = await http.get(url, headers: headers);
  return JSONResponse(response.body, response.statusCode);
}

Future<JSONResponse> getJsonCache(String uri, dynamic headers) async {
  try {
    final res = await DefaultCacheManager().getSingleFile(
      uri,
      headers: headers,
    );

    if (await res.exists()) {
      return JSONResponse(await res.readAsString(), 200);
    }

    // Try normal request, then actually fail
    var url = Uri.parse(uri);
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      if (kDebugMode) print("Fetched from network.");

      // Shamelessly stolen from flutter_cache_manager src lol
      var ageDuration = const Duration(days: 7);
      final controlHeader = response.headers['Cache-Control'];
      if (controlHeader != null) {
        final controlSettings = controlHeader.split(',');
        for (final setting in controlSettings) {
          final sanitizedSetting = setting.trim().toLowerCase();
          if (sanitizedSetting == 'no-cache') {
            ageDuration = const Duration();
          }
          if (sanitizedSetting.startsWith('max-age=')) {
            var validSeconds = int.tryParse(sanitizedSetting.split('=')[1]) ?? 0;
            if (validSeconds > 0) {
              ageDuration = Duration(seconds: validSeconds);
            }
          }
        }
      }

      await DefaultCacheManager().putFile(uri, response.bodyBytes, eTag: response.headers['etag'], maxAge: ageDuration);
    }

    return JSONResponse(response.body, response.statusCode);
  } on HttpException catch (e) {
    var error = int.tryParse(e.message.replaceAll(RegExp(r'[^0-9]'), ''));
    return JSONResponse(null, error ?? 500);
  }
}
