import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const mkChannel = MethodChannel('sh.cider.android/musickit');

  String _devToken = "";
  String _usrToken = "";

  bool _isAuthenticated = false;

  Future<void> _musicKitAuthentication() async {
    // Fetch developer token via FETCH api.cider.sh
    var url = Uri.parse('https://api.cider.sh/v1');
    var res = await http.get(url, headers: {
      'user-agent': 'Cider/0.0.1',
    });

    if (res.statusCode != 200) throw Exception('Failed to fetch developer token');

    // Is this redundant?
    setState(() {
      _devToken = json.decode(res.body)['token'];
    });

    try {
      // Authenticate with MusicKit
      var token = await mkChannel.invokeMethod('auth', {'devToken': _devToken});
      setState(() {
        _usrToken = token;
        _isAuthenticated = true;
      });
    } on PlatformException catch (e) {
      print(e.message);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    _musicKitAuthentication().then((_) {
      setState(() {
        _isAuthenticated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MaterialApp(
      title: 'Cider',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cider Mobile Test'),
        ),
        body: Center(
          child: Text('DEV $_devToken USR $_usrToken'),
        ),
      ),
    );
  }
}
