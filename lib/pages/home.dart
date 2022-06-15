import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'basepage.dart';

import 'package:cider_mobile/components/media_listitem.dart';

class HomeScreen extends BasePage {
  const HomeScreen({Key? key, required super.amAPICall}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recentlyPlayed = <String, MediaType>{};

  // This is where you'll get the song data from the Apple Music API
  // (among other things)
  Future<void> asyncInit() async {
    final res = await widget.amAPICall("me/recent/played", {
      "limit": 10,
    });
    if (res['errors'] != null) return;

    setState(() {
      for (final song in res['data']) {
        _recentlyPlayed.addEntries(
          <MapEntry<String, MediaType>>[
            MapEntry<String, MediaType>(
                song['id'], MediaType.values.firstWhere((element) => "${element.name}s" == song['type'])),
          ],
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    final list = _recentlyPlayed.entries.map(
      (e) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 200,
            child: MediaListItem(
              amAPICall: widget.amAPICall,
              id: e.key,
              type: e.value,
            ),
          ),
        );
      },
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...list,
        ],
      ),
    );
  }
}
