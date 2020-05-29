import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget error;
  final BoxFit fit;
  final double size;

  const CustomNetworkImage(
    this.imageUrl, {
    Key key,
    this.placeholder,
    this.error,
    this.fit,
    this.size = 45,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        height: size,
        width: size,
        child: CachedNetworkImage(
          imageUrl: imageUrl ??
              defaultUserImageURL,
          fit: fit ?? BoxFit.fitWidth,
          placeholder: (context, url) => Center(
            child: placeholder ?? CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
