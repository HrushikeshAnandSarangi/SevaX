import 'dart:io';
import 'package:sevaexchange/flavor_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:sevaexchange/auth/auth.dart';
//import 'package:sevaexchange/auth/auth_provider.dart';
//import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
//import 'package:sevaexchange/main.dart';
//import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
//import 'package:sevaexchange/models/user_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class Congrats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CongratsState();
  }
}

class _CongratsState extends State<Congrats> {
  String _timeBankStr = 'Newzeland';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              logo,
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                'You have been added to the $_timeBankStr timebank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.black26,
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: RaisedButton(
                            child: Text('Proceed',),
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: () {
                              print('Pressed proceed btn');
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          )
      ),
    );
  }
  Widget get logo {
    return Container(
      child: Column(
        children: <Widget>[
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Text(
            'Humanity\nFirst'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 5,
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          )
              : Offstage(),
          SizedBox(
            height: 16,
          ),
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Image.asset(
            'lib/assets/Y_from_Andrew_Yang_2020_logo.png',
            height: 70,
            fit: BoxFit.fill,
            width: 80,
          )
              : FlavorConfig.appFlavor == Flavor.TULSI
              ? SvgPicture.asset(
            'lib/assets/tulsi_icons/tulsi2020_icons_tulsi2020-logo.svg',
            height: 100,
            fit: BoxFit.fill,
            width: 100,
            color: Colors.white,
          )
              : FlavorConfig.appFlavor == Flavor.TOM
              ? SvgPicture.asset(
            'lib/assets/ts2020-logo-w.svg',
            height: 90,
            fit: BoxFit.fill,
            width: 90,
          )
              : Image.asset(
            'lib/assets/images/seva-x-logo.png',
            height: 80,
            fit: BoxFit.fill,
            width: 280,
          )
        ],
      ),
    );
  }
}
