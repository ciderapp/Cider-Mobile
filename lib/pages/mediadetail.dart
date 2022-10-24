import 'package:flutter/material.dart';

import 'package:cider_mobile/misc.dart';
import 'package:cider_mobile/http/amapi.dart';

class MediaDetailItem extends StatelessWidget {
  final JSON attributes;
  final int index;

  const MediaDetailItem({Key? key, required this.index, required this.attributes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$index.",
              style: Theme.of(context).primaryTextTheme.headline4,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attributes['name'],
                  style: Theme.of(context).textTheme.headline6,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "${attributes['artistName']} — ${attributes['albumName']}",
                  style: Theme.of(context).textTheme.subtitle1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MediaDetail extends StatefulWidget {
  final AMAPI amAPI;
  final String id;
  final MediaType type;

  const MediaDetail({Key? key, required this.amAPI, required this.id, required this.type}) : super(key: key);

  @override
  State<MediaDetail> createState() => _MediaDetailState();
}

class _MediaDetailState extends State<MediaDetail> {
  var _name = "Track View";
  var _artist = "";
  final _tracks = <JSON>[];

  void _init() async {
    final res = await widget.amAPI.catalog('${widget.type.name}s/${widget.id}');
    if (res is List<AMError>) {
      return;
    }

    setState(() {
      _name = res[0]['attributes']['name'];

      switch (widget.type) {
        case MediaType.album:
        case MediaType.song:
          _artist = res[0]['attributes']['artistName'];
          break;
        case MediaType.playlist:
          _artist = res[0]['attributes']['curatorName'];
          break;
        default:
          _artist = "";
      }
    });

    var tracks = res[0]['relationships']['tracks']['data'].map((e) => e['id']);

    // Stupid Apple limitation
    for (var i = 0; i < tracks.length; i += 300) {
      var query = [...tracks].skip(i).take(300).join(",");
      final res = await widget.amAPI.catalog('songs', {
        'ids': query,
      });
      if (res is List<AMError>) {
        return;
      }

      res.forEach((e) => _tracks.add(e['attributes']));
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var tracks = _tracks.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: MediaDetailItem(
            index: _tracks.indexOf(e) + 1,
            attributes: e,
          ),
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
      ),
      body: Center(
        child: Column(
          children: [
            Text("$_name by $_artist"),
            Expanded(
              child: ListView(
                children: [
                  ...tracks,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
