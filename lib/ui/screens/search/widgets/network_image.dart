import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget error;
  final BoxFit fit;

  const CustomNetworkImage(
    this.imageUrl, {
    Key key,
    this.placeholder,
    this.error,
    this.fit,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? defaultUserImageURL,
      fit: fit ?? BoxFit.fitWidth,
      placeholder: (context, url) => Center(
        child: placeholder ?? CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Center(
        child: FadeInImage.assetNetwork(
          height: 70,
          width: 70,
          image: defaultUserImageURL,
          placeholder: defaultUserImageURL,
        ),
      ),
    );
  }
}
