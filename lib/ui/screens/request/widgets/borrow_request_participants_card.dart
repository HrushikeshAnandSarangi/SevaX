import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';

class BorrowRequestParticipantsCard extends StatelessWidget {
  final Padding padding;
  final String imageUrl;
  final String name;
  final String email;
  final Function onImageTap;
  final Widget buttonsContainer;

  const BorrowRequestParticipantsCard(
      {Key key,
      this.padding,
      this.imageUrl,
      this.name,
      this.email,
      this.onImageTap,
      this.buttonsContainer = const SizedBox()})
      : assert(name != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomNetworkImage(
                        imageUrl ?? defaultUserImageURL,
                        fit: BoxFit.cover,
                        onTap: onImageTap,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 115,
                      child: Text(
                        name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email, //add date on which potential borrower requested
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(width: 8),
                buttonsContainer
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(//Check if Item or Place and show relevant image
                      'Umesh To Add Place or Items Widget Here From Lender Items'),
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.grey[100],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}
