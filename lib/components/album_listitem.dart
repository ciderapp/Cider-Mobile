import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:cider_mobile/misc.dart';

class AlbumListItem extends StatelessWidget {
  final String imageURL;

  const AlbumListItem({Key? key, required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pxr = MediaQuery.of(context).devicePixelRatio;
        final width = (constraints.maxWidth * pxr).toInt();
        final height = (constraints.maxHeight * pxr).toInt();

        final placeholder = SvgPicture.asset(
          "assets/MissingArtwork.svg",
          width: width.toDouble(),
          height: height.toDouble(),
        );

        if (imageURL == "") {
          return placeholder;
        }

        final url = imageURL.replaceAll("{w}", "$width").replaceAll("{h}", "$height");
        return CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => placeholder,
        );
      },
    );
  }
}
