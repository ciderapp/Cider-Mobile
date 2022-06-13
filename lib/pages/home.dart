import 'package:flutter/material.dart';
import 'basepage.dart';

class HomeScreen extends BasePage {
  const HomeScreen({Key? key, required super.amAPICall}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _string = "";

  Future<void> asyncInit() async {
    // This is where you'll get the song data from the Apple Music API
    final res = await widget.amAPICall("me/recent/played/tracks", {
      "limit": "1",
    });
    if (res['errors'] == null) {
      setState(() {
        _string = "${res['data'][0]['attributes']['name']} by ${res['data'][0]['attributes']['artistName']}";
      });
    } else {
      setState(() {
        _string = "Error";
      });
    }
  }

  @override
  void initState() {
    super.initState();

    asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Home \n$_string',
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}
