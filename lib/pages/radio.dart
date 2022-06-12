import 'package:flutter/material.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Radio',
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}
