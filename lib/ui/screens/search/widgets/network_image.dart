import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    return ClipOval(
      child: SizedBox(
        height: 45,
        width: 45,
        child: CachedNetworkImage(
          imageUrl: imageUrl ??
              "https://getuikit.com/v2/docs/images/placeholder_600x400.svg",
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
