import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:sevaexchange/constants/sevatitles.dart';

class ExploreFeaturedCard extends StatelessWidget {
  const ExploreFeaturedCard({
    Key? key,
    this.imageUrl,
    this.communityName,
    this.textStyle,
    this.onTap,
    required this.padding,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String? imageUrl;
  final String? communityName;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Image.network(
                    imageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                communityName ?? '',
                style: textStyle ??
                    const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
