import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:cider_mobile/misc.dart';

class MediaListItem extends StatefulWidget {
  final AMAPICallback amAPICall;
  final String id;
  final MediaType type;
  final VoidCallback onTap;

  const MediaListItem({Key? key, required this.amAPICall, required this.id, required this.type, required this.onTap})
      : super(key: key);

  @override
  State<MediaListItem> createState() => _MediaListItemState();
}

class _MediaListItemState extends State<MediaListItem> {
  Map<String, dynamic>? _attributes;

  void _fetchAlbum() async {
    if (widget.id == "") return;
    if (widget.type == MediaType.unknown) return;

    // TODO: Proper Storefront ID handling
    final res = await widget.amAPICall(
      "catalog/us/${widget.type.name}s/${widget.id}",
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
  void didUpdateWidget(MediaListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _fetchAlbum();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth * MediaQuery.of(context).devicePixelRatio).toInt();

        final placeholder = SvgPicture.asset(
          "assets/MissingArtwork.svg",
          width: constraints.maxWidth,
          height: constraints.maxWidth,
        );

        var name = "";
        var artistName = "";

        var bgColor = Theme.of(context).primaryColor;
        var txtColor1 = Theme.of(context).textTheme.subtitle1!.color;
        var txtColor2 = Theme.of(context).textTheme.subtitle2!.color;

        Widget image = placeholder;
        if (_attributes != null) {
          final url = _attributes!['artwork']['url'].replaceAll("{w}", "$size").replaceAll("{h}", "$size");
          image = CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (context, url) => placeholder,
            errorWidget: (context, url, error) => placeholder,
            width: constraints.maxWidth,
            height: constraints.maxWidth,
          );

          if (widget.type != MediaType.song) print(_attributes);

          name = _attributes!['name'];
          switch (widget.type) {
            case MediaType.playlist:
              //artistName = _attributes!['description']['short'];
              artistName = _attributes!['curatorName'];
              break;
            case MediaType.station:
              artistName = "Station";
              break;
            default:
              artistName = _attributes!['artistName'];
          }

          print("MediaListItem: $name");
          print("Artist Name: $artistName");

          if (name == "") name = "Unknown ${widget.type.name}";
          if (artistName == "") artistName = "Unknown Artist";

          if (_attributes!['artwork']['bgColor'] != null) {
            bgColor = Color(0xFF000000 | int.parse(_attributes!['artwork']['bgColor'], radix: 16));
          }
          if (_attributes!['artwork']['textColor1'] != null) {
            txtColor1 = Color(0xFF000000 | int.parse(_attributes!['artwork']['textColor1'], radix: 16));
          }
          if (_attributes!['artwork']['textColor3'] != null) {
            txtColor2 = Color(0xFF000000 | int.parse(_attributes!['artwork']['textColor3'], radix: 16));
          }
        }

        return ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              //splashFactory: NoSplash.splashFactory,
              maximumSize: Size(constraints.maxWidth, double.infinity),
              padding: EdgeInsets.zero,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                image,
                const SizedBox(
                  height: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  // TODO: Autoscroll on overflow
                  child: Text(
                    name,
                    softWrap: false,
                    // TODO: Figure out per-syllable elipsis
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: txtColor1,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    artistName,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: txtColor2,
                        ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
