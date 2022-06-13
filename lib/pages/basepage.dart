import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(String, [Map<String, dynamic>?]) amAPICall;

  const BasePage({Key? key, required this.amAPICall}) : super(key: key);
}
