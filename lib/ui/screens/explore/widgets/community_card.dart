import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard(
      {Key key,
      this.name,
      this.memberCount,
      this.imageUrl,
      this.buttonLabel,
      this.buttonColor,
      this.textColor,
      this.onbuttonPress,
      this.memberIds})
      : super(key: key);

  final String name;
  final String memberCount;
  final String imageUrl;
  final String buttonLabel;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onbuttonPress;
  final List<String> memberIds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl ??
                  'https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjEyMDd9',
              fit: BoxFit.cover,
              height: 80,
              width: 80,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  '${memberCount + ' ' + S.of(context).members}',
                  style: TextStyle(fontSize: 10),
                ),
//              Offstage(
//                  offstage: int.parse(memberCount) == 0,
//                child: FutureBuilder<List<String>>(
//                  future: getCommunityMembersImages(memberIds: memberIds),
//                  builder: (context, snapshot) {
//
//                      if(!snapshot.hasData){
//                          return Container();
//                      }
//                      return MemberImageStack(
//                          images: snapshot.data,
//                          radius: 10,
//                      );
////                  return MemberImageStack(
////                    images: [
////                      'https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjEyMDd9',
////                      'https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjEyMDd9',
////                      'https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjEyMDd9'
////                    ],
////                    radius: 10,
////                  );
//                  }
//                ),
//              )
              ],
            ),
          ),
          Spacer(),
          CustomElevatedButton(
            elevation: 0,
            child: Text(
              buttonLabel,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
            ),
            onPressed: onbuttonPress,
            color: buttonColor ?? Colors.white,
            textColor: textColor,
          ),
          SizedBox(width: 25),
        ],
      ),
    );
  }
}
