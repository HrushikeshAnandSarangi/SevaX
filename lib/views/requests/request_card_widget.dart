
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RequestCardWidget extends StatefulWidget {

  final UserModel userModel;

  RequestCardWidget({@required this.userModel});

  @override
  _RequestCardWidgetState createState() => _RequestCardWidgetState();
}

class _RequestCardWidgetState extends State<RequestCardWidget> {

bool isBookMarked = false;
var validItems;

  @override
  Widget build(BuildContext context) {
    return makeUserWidget();
  }


  Widget makeUserWidget() {
    return Container(
        margin: EdgeInsets.fromLTRB(35, 20, 30, 10),
        child: Stack(
            children: <Widget>[
              getUserCard(),
              getUserThumbnail(),
            ]
        )
    );
  }

  Widget getUserThumbnail() {
    return Container(
        margin: EdgeInsets.only(top: 20, right: 15),
        width: 60.0,
        height: 60.0,
        decoration:  BoxDecoration(
            shape: BoxShape.circle,
            image:  DecorationImage(
                fit: BoxFit.fill,
                image:  NetworkImage(
                    "https://www.itl.cat/pngfile/big/43-430987_cute-profile-images-pic-for-whatsapp-for-boys.jpg")
            )
        ));
  }

  Widget getUserCard({BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 220,
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
                    child: Text("Tony Stark", style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),),
                  ),
//              Spacer(),
                  InkWell(

                    onTap: () {
                      setState(() {
                        isBookMarked = !isBookMarked;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        isBookMarked ?

                        Icon(
                          Icons.bookmark, color: Colors.redAccent,
                          size: 35,
                        ) : Icon(
                          Icons.bookmark,
                          color: Colors.grey,
                          size: 35,
                        ),
                      ],
                    ),
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
                  spacing: 1.0
              ),
              SizedBox(
                  height: 10
              ),
              Expanded(
                child: Text(
                  "Bio",
                  maxLines: 3,
                  style: TextStyle(color: Colors.black, fontSize: 12,),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(

                  /*  decoration: BoxDecoration(

                        boxShadow: [BoxShadow(
                            color: Colors.indigo[50],
                            blurRadius: 1,
                            offset: Offset(0.0, 0.50)
                        )]
                    ),*/
                    height: 40,

                    padding: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                      shape: StadiumBorder(),
                      color: Colors.indigo,
                      textColor: Colors.white,
                      elevation: 5,
                      onPressed: () {},
                      child: const Text(
                          'Invited',
                          style: TextStyle(fontSize: 14)
                      ),
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


  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }
}
TextStyle get sectionTextStyle {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 11,
    color: Colors.grey,
  );

}
Widget getEmptyWidget(String title, String notFoundValue) {
  return Center(
    child: Text(
      notFoundValue,
      overflow: TextOverflow.ellipsis,
      style: sectionHeadingStyle,
    ),
  );
}

TextStyle get sectionHeadingStyle {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    color: Colors.black,
  );
}
