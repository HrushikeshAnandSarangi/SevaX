import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class MemberCardWithSingleAction extends StatelessWidget {
  final String name;
  final String timestamp;
  final String photoUrl;
  final Function onMessagePressed;
  final Function onImageTap;
  final Function action;
  final String status;
  final Color buttonColor;
  const MemberCardWithSingleAction({
    Key key,
    this.name,
    this.timestamp,
    this.photoUrl,
    this.onMessagePressed,
    this.action,
    this.status,
    this.buttonColor,
    this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: CustomNetworkImage(
                photoUrl ?? defaultUserImageURL,
                fit: BoxFit.cover,
                onTap: onImageTap,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  timestamp,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          // IconButton(
          //   icon: Icon(Icons.chat),
          //   onPressed: onMessagePressed,
          // ),
          Container(
            height: 30,
            child: CustomElevatedButton(
              color: buttonColor,
              child: Text(status),
              onPressed: action,
            ),
          ),
        ],
      ),
    );
  }
}
