import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
//import 'package:sevaexchange/constants/sevatitles.dart';

class ExploreRequestsCard extends StatelessWidget {
  const ExploreRequestsCard(
      {Key? key,
      this.imageUrl,
      this.communityName,
      this.city,
      this.description,
      this.userIds,
      this.firstTextStyle,
      this.secondTextStyle,
      this.onTap,
      this.requestDate
      //this.padding,
      })
      : super(key: key);

  final VoidCallback? onTap;
  final String? imageUrl;
  final String? communityName;
  final String? city;
  final String? description;
  final List<String>? userIds;
  final TextStyle? firstTextStyle;
  final TextStyle? secondTextStyle;
  final String? requestDate;
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
                //Card(
                // borderOnForeground: false,
                // elevation: 1,
                //child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Image.network(
                      imageUrl ?? 'https://placeholder.com/image',
                      width: 300,
                      height: 150,
                      fit: BoxFit.cover),
                ),
                //),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5),
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          communityName?.toUpperCase() ?? '',
                          style: firstTextStyle ??
                              const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        Text(
                          city != null && city?.isNotEmpty == true
                              ? ' - ${city!.toUpperCase()}'
                              : '',
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
                      description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: secondTextStyle ??
                          const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                MemberAvatarListWithCount(userIds: userIds ?? [], radius: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    requestDate?.toUpperCase() ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 13,
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
