import 'package:flutter/material.dart';
import 'basepage.dart';

import 'package:cider_mobile/misc.dart';
import 'package:cider_mobile/pages/mediadetail.dart';
import 'package:cider_mobile/components/media_listitem.dart';

class HomeScreen extends BasePage {
  const HomeScreen({Key? key, required super.amAPICall}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recentlyPlayed = <String, MediaType>{};
  final _madeforyou = <String, MediaType>{};

  // This is where you'll get the song data from the Apple Music API
  // (among other things)
  Future<void> asyncInit() async {
    var res = await widget.amAPICall("me/recent/played", {
      "limit": 10,
    });
    if (res['error'] != null && res['errors'] != null) return;

    setState(() {
      for (final song in res['data']) {
        print(song);
        print(song['id']);
        print(song['type']);
        _recentlyPlayed.addEntries(
          <MapEntry<String, MediaType>>[
            MapEntry<String, MediaType>(
                song['id'],
                MediaType.values
                    .firstWhere((element) => "${element.name}s" == song['type'], orElse: () => MediaType.unknown)),
          ],
        );
      }
    });

    res = await widget.amAPICall("me/recommendations", {
      "limit": 10,
    });
    if (res['errors'] != null) return;

    setState(() {
      for (final song in res['data'][0]['relationships']['contents']['data']) {
        _madeforyou.addEntries(
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
    // Recently Played
    // TODO: Figure out how to use ListView.builder without it throwing a fit about height
    final list = _recentlyPlayed.entries.map(
      (e) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 16,
          ),
          child: SizedBox(
            width: 200,
            child: MediaListItem(
              amAPICall: widget.amAPICall,
              id: e.key,
              type: e.value,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MediaDetail(
                      amAPICall: widget.amAPICall,
                      id: e.key,
                      type: e.value,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    // Recently Played
    // TODO: Figure out how to use ListView.builder without it throwing a fit about height
    final mlist = _madeforyou.entries.map(
      (e) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 16,
          ),
          child: SizedBox(
            width: 200,
            child: MediaListItem(
              amAPICall: widget.amAPICall,
              id: e.key,
              type: e.value,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MediaDetail(
                      amAPICall: widget.amAPICall,
                      id: e.key,
                      type: e.value,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    // Oh god this is so bad lmao
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Recently Played",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...list,
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Made for You",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...mlist,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.only(
            top: 4,
            bottom: 12,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Recently Played",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...list,
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Made for you",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...mlist,
            ],
          ),
        ),
      ],
    );
  }
}
