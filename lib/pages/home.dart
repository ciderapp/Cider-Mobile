import 'package:flutter/material.dart';
import 'basepage.dart';

import 'package:cider_mobile/components/media_listitem.dart';

class HomeScreen extends BasePage {
  const HomeScreen({Key? key, required super.amAPICall}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _albumID = "";

  // This is where you'll get the song data from the Apple Music API
  // (among other things)
  Future<void> asyncInit() async {
    final res = await widget.amAPICall("me/recent/played", {
      "limit": "1",
    });
    if (res['errors'] != null) return;

    setState(() {
      _albumID = res['data'][0]['id'];
    });
  }

  @override
  void initState() {
    super.initState();

    asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: MediaListItem(
            amAPICall: widget.amAPICall,
            id: _albumID,
            type: MediaType.album,
          ),
        ),
      ],
    );
  }
}
