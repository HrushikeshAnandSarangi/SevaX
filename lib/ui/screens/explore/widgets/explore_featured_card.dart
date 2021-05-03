import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:sevaexchange/constants/sevatitles.dart';

class ExploreFeaturedCard extends StatelessWidget {
  const ExploreFeaturedCard({
    Key key,
    this.imageUrl,
    this.communityName,
    this.textStyle,
    this.onTap,
    //this.padding,
  }) : super(key: key);

  final VoidCallback onTap;
  final String imageUrl;
  final String communityName;
  final TextStyle textStyle;
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
            Column(
              children: [
                //Card(
                //  borderOnForeground: false,
                //  elevation: 1,
                //  child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Image.network(imageUrl,
                      height: 200, width: 250, fit: BoxFit.contain),
                  //  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Container(
                    width: 180,
                    child: Text(
                      communityName,
                      style: textStyle ??
                          const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
