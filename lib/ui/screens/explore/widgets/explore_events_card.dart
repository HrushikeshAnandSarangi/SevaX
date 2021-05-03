import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:sevaexchange/constants/sevatitles.dart';

class ExploreEventsCard extends StatelessWidget {
  const ExploreEventsCard({
    Key key,
    this.imageUrl,
    this.communityName,
    this.city,
    this.description,
    this.participantsImageList,
    this.firstTextStyle,
    this.secondTextStyle,
    this.onTap,
    //this.padding,
  }) : super(key: key);

  final VoidCallback onTap;
  final String imageUrl;
  final String communityName;
  final String city;
  final String description;
  final List<String> participantsImageList;
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
                    child: Image.network(imageUrl,
                        fit: BoxFit.cover, width: 300, height: 150),
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
                          communityName != null
                              ? communityName.toUpperCase()
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
                    width: 250,
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
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 9,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.transparent,
                                  backgroundImage:
                                      participantsImageList[index] != null
                                          ? NetworkImage(
                                              participantsImageList[index])
                                          : null,
                                ),
                                const SizedBox(width: 2),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
