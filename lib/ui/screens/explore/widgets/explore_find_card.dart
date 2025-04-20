import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExploreFindCard extends StatelessWidget {
  const ExploreFindCard({
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
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10),
      child: InkWell(
        onTap: onTap,
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Card(
              elevation: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network(imageUrl ?? ''),
                  const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: Text(
                      title ?? '',
                      style: style ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
