import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RequestInviteUserCard extends StatefulWidget {
  @override
  _RequestInviteUserCardState createState() => _RequestInviteUserCardState();
}

class _RequestInviteUserCardState extends State<RequestInviteUserCard> {
  bool bookMarked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
          margin: EdgeInsets.fromLTRB(35, 100, 30, 10),
          child: Stack(children: <Widget>[
            getUserCard(),
            getUserThumbnail(),
          ])),
    );
  }

  Widget getUserThumbnail() {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 15),
      width: 60.0,
      height: 60.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          fit: BoxFit.fill,
          image: new NetworkImage(
              "https://www.itl.cat/pngfile/big/43-430987_cute-profile-images-pic-for-whatsapp-for-boys.jpg"),
        ),
      ),
    );
  }

  Widget getUserCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 250,
        width: 500,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Tony Stark",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    child: Icon(
                      !bookMarked ? Icons.bookmark_border : Icons.bookmark,
                      color: Colors.redAccent,
                    ),
                    onTap: () {
                      bookMarked = !bookMarked;
                      print(bookMarked);
                      setState(() {});
                    },
                  ),
                ],
              ),
              SmoothStarRating(
                  allowHalfRating: true,
                  onRatingChanged: (v) {
//                    rating = v;
//                    setState(() {});
                  },
                  starCount: 5,
                  rating: 3.5,
                  size: 20.0,
                  filledIconData: Icons.star,
                  halfFilledIconData: Icons.star_half,
                  defaultIconData: Icons.star_border,
                  color: Colors.orangeAccent,
                  borderColor: Colors.orangeAccent,
                  spacing: 1.0),
              SizedBox(height: 10),
              Expanded(
                child: Text(
                  "Tony Stark Tony StarkTony StarkTony StarkTony StarkTony StarkTony StarkTony StarkTony StarkTony StarkTony StarkTony StarkTony Stark",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    height: 33,
                    width: 80,
                    child: RaisedButton(
                      shape: StadiumBorder(),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {},
                      child:
                          const Text('Invite', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
