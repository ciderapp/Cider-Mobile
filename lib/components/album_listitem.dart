import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:cider_mobile/misc.dart';

class AlbumListItem extends StatefulWidget {
  final AMAPICallback amAPICall;
  final String albumID;

  const AlbumListItem({Key? key, required this.amAPICall, required this.albumID}) : super(key: key);

  @override
  State<AlbumListItem> createState() => _AlbumListItemState();
}

class _AlbumListItemState extends State<AlbumListItem> {
  Map<String, dynamic>? _attributes;

  void _fetchAlbum() async {
    if (widget.albumID == "") return;

    // TODO: Proper Storefront ID handling
    final res = await widget.amAPICall(
      "catalog/us/albums/${widget.albumID}",
    );

    if (res['error'] != null) return;

    setState(() {
      _attributes = res['data'][0]['attributes'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAlbum();
  }

  @override
  void didUpdateWidget(AlbumListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.albumID != widget.albumID) {
      _fetchAlbum();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pxr = MediaQuery.of(context).devicePixelRatio;
        final width = ((constraints.maxWidth * pxr) * .5).toInt();
        final height = ((constraints.maxHeight * pxr) * .5).toInt();

        final placeholder = SvgPicture.asset(
          "assets/MissingArtwork.svg",
          width: width.toDouble(),
          height: height.toDouble(),
        );

        var albumName = "";
        var artistName = "";

        Widget image = placeholder;
        if (_attributes != null) {
          final url = _attributes!['artwork']['url'].replaceAll("{w}", "$width").replaceAll("{h}", "$height");
          image = CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => placeholder,
            errorWidget: (context, url, error) => placeholder,
            width: width.toDouble(),
            height: height.toDouble(),
          );

          albumName = _attributes!['name'];
          artistName = _attributes!['artistName'];
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: image,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                albumName,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                artistName,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
          ),
        );
      },
    );
  }
}
