import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:sevaexchange/constants/sevatitles.dart';

class ExploreOffersCard extends StatelessWidget {
  const ExploreOffersCard({
    Key key,
    this.imageUrl,
    this.offerName,
    this.city,
    this.description,
    this.firstTextStyle,
    this.secondTextStyle,
    this.onTap,
    //this.padding,
  }) : super(key: key);

  final VoidCallback onTap;
  final String imageUrl;
  final String offerName;
  final String city;
  final String description;
  final TextStyle firstTextStyle;
  final TextStyle secondTextStyle;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  elevation: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Image.network(
                      imageUrl,
                      height: 150,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5),
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          offerName != null
                              ? offerName.toUpperCase()
                              : 'COMMUNITY NAME UNAVAILABLE',
                          style: firstTextStyle ??
                              const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        Text(
                          ' - ',
                          style: firstTextStyle ??
                              const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        Text(
                          city != null
                              ? city.toUpperCase()
                              : 'CITY UNAVAILABLE',
                          style: firstTextStyle ??
                              const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5),
                  child: Container(
                    width: 220,
                    child: Text(
                      description,
                      style: secondTextStyle ??
                          const TextStyle(
                            fontSize: 17,
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
