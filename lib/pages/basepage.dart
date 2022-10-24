import 'package:flutter/material.dart';

import 'package:cider_mobile/http/amapi.dart';

abstract class BasePage extends StatefulWidget {
  final AMAPI amAPI;

  const BasePage({Key? key, required this.amAPI}) : super(key: key);
}
