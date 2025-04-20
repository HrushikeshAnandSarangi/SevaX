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
    //this.padding,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String? imageUrl;
  final String? communityName;
  final TextStyle? textStyle;
  //final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 300,
          width: 150,
          child: Column(
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
