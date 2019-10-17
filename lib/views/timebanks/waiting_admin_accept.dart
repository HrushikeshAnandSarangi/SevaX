import 'package:flutter/material.dart';

class WaitingView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _waitingState();
  }

}


class _waitingState extends State<WaitingView> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('',textAlign: TextAlign.center,style: TextStyle(fontSize: 20.0),),),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              logo,
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                'Waiting for admin acceptance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                'Your request has been sent to admin, we will notify you once admin approves your request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black45,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),

            ],
          )
      ),
    );
  }
  Widget get logo {
//    lib/assets/images/waiting.jpg
    AssetImage assetImage = AssetImage('lib/assets/images/waiting.jpg');
    Image image = Image(image: assetImage,width: 300,height: 300,);

    // TODO: implement build
    return Container(child:image,);
  }
}