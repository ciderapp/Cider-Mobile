import 'package:flutter/material.dart';

class ListenScreen extends StatelessWidget {
  const ListenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Listen Now',
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}
