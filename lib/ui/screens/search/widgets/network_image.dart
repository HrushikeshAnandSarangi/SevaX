import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget error;
  final BoxFit fit;
  final double size;
  final bool clipOval;

  const CustomNetworkImage(
    this.imageUrl, {
    Key key,
    this.placeholder,
    this.error,
    this.fit,
    this.size = 45,
    this.clipOval = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: size,
      width: size,
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? defaultUserImageURL,
        fit: fit ?? BoxFit.fitWidth,
        placeholder: (context, url) => Center(
          child: placeholder ?? CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(Icons.error),
        ),
      ),
    );
    return clipOval ? ClipOval(child: child) : child;
  }
}
