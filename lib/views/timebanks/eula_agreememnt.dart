import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'EULAgreement.dart';

class EulaAgreement extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EulaAgreementState();
  }
}

class EulaAgreementState extends State<EulaAgreement> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0.5,
              // leading: BackButton(
              //   color: Colors.white,
              // ),
              title: new Text(
                'EULA Agreement',
                style: TextStyle(
                  // color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: ListView(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                        ),
                        Text(
                          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                              ? EULAgreementScript.EULA_AGREEMENT
                              : EULAgreementScript.SEVA_EULA_AGREEMENT,
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
                        Row(
                          children: <Widget>[
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  print("selected value ${value}");
                                  userAcceptanceStatus = value;
                                });
                              },
                              value: userAcceptanceStatus,
                            ),
                            Expanded(
                              child: Text(
                                'I agree that i will be willing to be bound by these terms and conditions.',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black45,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                            // height: 39,
                            width: 220,
                            child: RaisedButton(
                              onPressed: userAcceptanceStatus
                                  ? () {
                                      print("Accepted EULA");
                                      Navigator.pop(
                                          context, {'response': 'ACCEPTED'});
                                    }
                                  : null,
                              child: Text(
                                'Proceed',
                                style:
                                    Theme.of(context).primaryTextTheme.button,
                              ),
                              // color: Theme.of(context).accentColor,
                              // textColor: FlavorConfig.values.buttonTextColor,
                              // shape: StadiumBorder(),
                            )),
                        SizedBox(height: 20),
                      ],
                    )),
              ],
            )));
  }

  bool userAcceptanceStatus = false;

  Widget get logo {
    AssetImage assetImage = AssetImage('lib/assets/images/waiting.jpg');
    Image image = Image(
      image: assetImage,
      width: 300,
      height: 300,
    );

    return Container(
      child: image,
    );
  }
}
