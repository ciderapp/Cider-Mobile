import 'package:flutter/material.dart';

import 'package:cider_mobile/misc.dart';

abstract class BasePage extends StatefulWidget {
  final AMAPICallback amAPICall;

  const BasePage({Key? key, required this.amAPICall}) : super(key: key);
}
