import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'components/rounded_navbar.dart';

// Pages
import 'pages/home.dart';
import 'pages/listen.dart';
import 'pages/browse.dart';
import 'pages/radio.dart';

void main() {
  runApp(const MyApp());
}

Future<dynamic> getJson(String uri, dynamic headers) async {
  var url = Uri.parse(uri);
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }

  return {'statusCodeError': response.statusCode, 'response': response.body};
}

Future<dynamic> getJsonCache(String uri, dynamic headers) async {
  try {
    final res = await DefaultCacheManager().getSingleFile(
      uri,
      headers: headers,
    );

    if (await res.exists()) {
      return json.decode(await res.readAsString());
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
      return json.decode(response.body);
    }

    return {'statusCodeError': response.statusCode, 'response': response.body};
  } on HttpException catch (e) {
    var error = int.tryParse(e.message.replaceAll(RegExp(r'[^0-9]'), ''));
    return {'statusCodeError': error};
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mkChannel = const MethodChannel('sh.cider.android/musickit');
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  int _page = 0;

  String _devToken = "";
  String _usrToken = "";

  bool _isAuthenticated = false;

  bool _hasErrored = false;
  String _errorMessage = "";

  // MusicKit API
  Future<Map<String, dynamic>> amAPI(String endpoint, [Map<String, dynamic>? query]) async {
    if (_usrToken.isEmpty) {
      return {'error': 'User token is empty'};
    }

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
    if (res['statusCodeError'] != null) {
      setState(() {
        _errorMessage = "Call to amAPI endpoint $endpoint failed with status code ${res['statusCodeError']}";
      });
      // TODO: Create a consistent error system/syntax
      if (kDebugMode) print("You've fucked up. Figure out what. ${res['statusCodeError']} ${res['response']}");
      setState(() => _hasErrored = true);
      return {'error': res['statusCodeError']};
    }

    return res;
  }

  // MusicKit initialization
  Future<void> _musicKitAuthentication() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    // Fetch developer token via FETCH api.cider.sh
    final res = await getJson("https://api.cider.sh/v1", {
      'user-agent': 'Cider/$version',
    });
    if (res['statusCodeError'] != null) {
      if (kDebugMode) print("Error fetching developer token: ${res['statusCodeError']}");
      // TODO: Check if internet is connected
      setState(() {
        _errorMessage = "Error fetching Apple Music Token. Cider API may be down.";
      });
      return;
    }

    // Not in a 'setState' because this does not change the state of the app
    _devToken = res['token'];

    var usrToken = await storage.read(key: "usrToken");
    if (usrToken != null) {
      _usrToken = usrToken;
      // Verify user token
      final res = await amAPI("me/library/songs", {
        'limit': 10,
      });
      if (res['error'] != null) {
        // Invalid token, delete it
        await storage.delete(key: "usrToken");
      } else if (res['errors'] == null) {
        setState(() {
          _isAuthenticated = true;
        });
      }
      _hasErrored = false;
    }

    if (!_isAuthenticated) {
      // Authenticate user with MusicKit
      try {
        var token = await mkChannel.invokeMethod('auth', {'devToken': _devToken});
        if (token != null) {
          await storage.write(key: "usrToken", value: token);
          setState(() {
            _usrToken = token;
            _isAuthenticated = true;
          });
        }
      } on PlatformException catch (e) {
        if (kDebugMode) print(e.message);
        setState(() {
          _isAuthenticated = false;
        });
      } on Exception catch (e) {
        if (kDebugMode) print(e.toString());
        setState(() {
          _isAuthenticated = false;
        });
      }
    }

    if (!_isAuthenticated) {
      setState(() {
        _hasErrored = true;
        _errorMessage = "Failed to authenticate user";
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _musicKitAuthentication();

    mkChannel.invokeMethod('initPlayer', {'devToken': _devToken, 'usrToken': _usrToken}).ignore();
    print("test?");
  }

  @override
  void dispose() {
    mkChannel.invokeMethod('destroyPlayer');
    super.dispose();
  }

  // Rendering

  @override
  Widget build(BuildContext context) {
    // Disable rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // The black screen of death
    // Show error message (if there is one)
    if (_hasErrored) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(
            color: Colors.red,
          ),
          textDirection: TextDirection.ltr,
        ),
      );
    }

    // TODO: Replace with Cider logo
    // Potentially place logo in progress indicator
    // Show loading indicator (if not authenticated)
    if (!_isAuthenticated) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Create Screens
    final List<Widget> pages = [
      HomeScreen(amAPICall: amAPI),
      const ListenScreen(),
      const BrowseScreen(),
      const RadioScreen(),
    ];

    // Show app
    return MaterialApp(
      title: 'Cider',
      theme: ThemeData(
        // Oh nice. Something to easily set colors throughout the app
        canvasColor: Colors.grey[900],
        primaryColor: Colors.grey[700],
        primaryTextTheme: Typography.whiteCupertino,
        textTheme: Typography.whiteCupertino,
        primaryIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              RoundedNavBar(
                items: const [
                  RoundedNavBarItem(
                    icon: Icon(Icons.home_outlined),
                    title: 'Home',
                  ),
                  RoundedNavBarItem(
                    icon: Icon(Icons.play_circle_outline),
                    title: 'Listen Now',
                  ),
                  RoundedNavBarItem(
                    icon: Icon(Icons.language_outlined),
                    title: 'Browse',
                  ),
                  RoundedNavBarItem(
                    icon: Icon(Icons.sensors_outlined),
                    title: 'Radio',
                  ),
                ],
                onTap: (index) {
                  if (kDebugMode) print('index $index');
                  setState(() {
                    _page = index;
                  });
                },
              ),
              const SizedBox(
                height: 2,
              ),
              pages[_page],
            ],
          ),
        ),
      ),
    );
  }
}
