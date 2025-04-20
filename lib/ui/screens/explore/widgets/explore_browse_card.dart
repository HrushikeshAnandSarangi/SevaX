import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExploreBrowseCard extends StatelessWidget {
  const ExploreBrowseCard({
    Key? key,
    this.imageUrl,
    this.title,
    this.style,
    this.onTap,
    //this.padding,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String? imageUrl;
  final String? title;
  final TextStyle? style;
  //final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        child: Container(
          height: 40,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    imageUrl ?? '',
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  title ?? '',
                  style: style ??
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
