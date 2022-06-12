import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Menu',
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}
