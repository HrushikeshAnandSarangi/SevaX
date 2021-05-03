import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExploreBrowseCard extends StatelessWidget {
  const ExploreBrowseCard({
    Key key,
    this.imageUrl,
    this.title,
    this.style,
    this.onTap,
    //this.padding,
  }) : super(key: key);

  final VoidCallback onTap;
  final String imageUrl;
  final String title;
  final TextStyle style;
  //final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Card(
            elevation: 1,
            child: Row(
              children: [
                Image.network(imageUrl),
                const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Text(
                    title,
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
      ),
    );
  }
}
