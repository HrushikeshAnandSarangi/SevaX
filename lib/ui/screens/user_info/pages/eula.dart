import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/main_app.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/user_info/utils/custom_router.dart';
import 'package:sevaexchange/views/timebanks/EULAgreement.dart';

class EulaPage extends StatefulWidget {
  final UserModel user;

  const EulaPage({Key key, this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EulaAgreementState();
  }
}

class EulaAgreementState extends State<EulaPage> {
  UserModel user;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.5,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              _signOut(context);
            },
          ),
          title: new Text(
            'EULA Agreement',
            style: TextStyle(
              fontSize: 18,
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
                                  user.acceptedEULA = true;
                                  print(user);
                                  Firestore.instance
                                      .collection('users')
                                      .document(user.email)
                                      .updateData({'acceptedEULA': true}).then(
                                          (onValue) {
                                    print("routing");
                                    customRouter(context: context, user: user);
                                  }).catchError((onError) {
                                    print("Error Updating introduction");
                                  });
                                }
                              : null,
                          child: Text(
                            'Proceed',
                            style: Theme.of(context).primaryTextTheme.button,
                          ),
                          // color: Theme.of(context).accentColor,
                          // textColor: FlavorConfig.values.buttonTextColor,
                          // shape: StadiumBorder(),
                        )),
                    SizedBox(height: 20),
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

  Future<void> _signOut(BuildContext context) async {
    Navigator.pop(context);
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MainApplication(),
      ),
    );
  }
}
