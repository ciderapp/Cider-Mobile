import 'package:flutter/material.dart';

import 'package:cider_mobile/misc.dart';

class MediaDetailItem extends StatelessWidget {
  final Map<String, dynamic> attributes;
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
  final AMAPICallback amAPICall;
  final String id;
  final MediaType type;

  const MediaDetail({Key? key, required this.amAPICall, required this.id, required this.type}) : super(key: key);

  @override
  State<MediaDetail> createState() => _MediaDetailState();
}

class _MediaDetailState extends State<MediaDetail> {
  var _name = "Track View";
  var _artist = "";
  final _tracks = <Map<String, dynamic>>[];

  void _init() async {
    final res = await widget.amAPICall(
      "catalog/us/${widget.type.name}s/${widget.id}",
    );
    if (res['error'] != null) return;

    setState(() {
      _name = res['data'][0]['attributes']['name'];
      _artist = res['data'][0]['attributes'][widget.type == MediaType.playlist ? 'curatorName' : 'artistName'];
    });

    var tracks = res['data'][0]['relationships']['tracks']['data'].map((e) => e['id']);

    // Stupid Apple limitation
    for (var i = 0; i < tracks.length; i += 300) {
      var query = [...tracks].skip(i).take(300).join(",");
      final res = await widget.amAPICall(
        "catalog/us/songs?ids=$query",
      );
      if (res['error'] != null) return;

      res['data'].forEach((e) => _tracks.add(e['attributes']));
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
