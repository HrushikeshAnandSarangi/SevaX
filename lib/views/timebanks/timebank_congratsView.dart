//import 'package:flutter/material.dart';
//
//class Congrats extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _CongratsState();
//  }
//}
//
//class _CongratsState extends State<Congrats> {
//  String _timeBankStr = 'Newzeland';
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Center(
//          child: Text(
//            'Congratulations',
//            textAlign: TextAlign.center,
//            style: TextStyle(fontSize: 20.0),
//          ),
//        ),
//      ),
//      body: Container(
//          padding: EdgeInsets.all(20.0),
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.all(10.0),
//              ),
//              logo,
//              Padding(
//                padding: EdgeInsets.all(10.0),
//              ),
//              Text(
//                'Congratulations!',
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontSize: 25.0,
//                  fontStyle: FontStyle.normal,
//                  color: Colors.black,
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.all(10.0),
//              ),
//              Text(
//                'You have been added to the $_timeBankStr timebank',
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontSize: 17.0,
//                  color: Colors.black26,
//                ),
//              ),
//              Column(
//                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: SizedBox(
//                          height: 50,
//                          child: RaisedButton(
//                            child: Text(
//                              'Proceed',
//                            ),
//                            textColor: Colors.white,
//                            color: Colors.blue,
//                            onPressed: () {
//                              Navigator.pop(context);
//                            },
//                            shape: RoundedRectangleBorder(
//                                borderRadius: BorderRadius.circular(10.0)),
//                          ),
//                        ),
//                      ),
//                    ],
//                  )
//                ],
//              ),
//            ],
//          )),
//    );
//  }
//
//  Widget get logo {
//    return Container(
//      child: Column(
//        children: <Widget>[
//          SizedBox(
//            height: 16,
//          ),
//          Image.asset(
//            'lib/assets/images/seva-x-logo.png',
//            height: 80,
//            fit: BoxFit.fill,
//            width: 280,
//          )
//        ],
//      ),
//    );
//  }
//}
