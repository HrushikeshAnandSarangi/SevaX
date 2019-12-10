import 'package:flutter/material.dart';
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
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              'EULA Agreement',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, color: Colors.white),
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
                      EULAgreementScript.EULA_AGREEMENT,
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
                    Container(
                      margin: EdgeInsets.all(20),
                      width: double.infinity,
                      child: RaisedButton(
                        child: Text(
                          'PROCEED',
                        ),
                        color: Colors.green,
                        onPressed: userAcceptanceStatus
                            ? () {
                                print("Accepted EULA");
                                // Firestore.instance
                                //     .collection('users')
                                //     .document(
                                //         SevaCore.of(context).loggedInUser.email)
                                //     .updateData({'acceptedEULA': false}).then(
                                //         (onValue) {
                                //   print("Param added to db");
                                // }).catchError((onError) {
                                //   print("Error crerating value");
                                // });
                                Navigator.pop(context, {'response' : 'ACCEPTED'});
                              }
                            : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                    ),
                  ],
                )),
          ],
        ));
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
