import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Widget? placeholder;
  final Widget? error;
  final BoxFit? fit;
  final double size;
  final bool clipOval;
  final String? entityName;
  final VoidCallback? onTap;

  const CustomNetworkImage(
    this.imageUrl, {
    Key? key,
    this.placeholder,
    this.error,
    this.fit,
    this.size = 45,
    this.clipOval = true,
    this.entityName,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: size,
      width: size,
      child: InkWell(
        onTap: onTap,
        child: CachedNetworkImage(
          imageUrl: imageUrl ?? (entityName != null ? '' : defaultUserImageURL),
          fit: fit ?? BoxFit.fitWidth,
          placeholder: (context, url) => Center(
            child: placeholder ?? LoadingIndicator(),
          ),
          errorWidget: (context, url, error) => entityName != null
              ? CustomAvatar(
                  name: entityName,
                )
              : Center(
                  child: Icon(Icons.error),
                ),
        ),
      ),
    );
    return clipOval ? ClipOval(child: child) : child;
  }
}
