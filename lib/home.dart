import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Home',
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}

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

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Browse',
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}

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
