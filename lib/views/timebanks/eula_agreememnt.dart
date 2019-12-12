import 'package:flutter/material.dart';
import 'EULAgreement.dart';
import 'package:sevaexchange/flavor_config.dart';

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
            centerTitle: true,
            elevation: 0.5,
            backgroundColor: Color(0xFFFFFFFF),
            leading: BackButton(color: Colors.black54),
            title: new Text('EULA Agreement',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w500))),
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
                    SizedBox(
                        height: 70,
                        width: 220,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: RaisedButton(
                            onPressed: userAcceptanceStatus
                                ? () {
                                    print("Accepted EULA");
                                    Navigator.pop(
                                        context, {'response': 'ACCEPTED'});
                                  }
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Proceed'),
                                ),
                              ],
                            ),
                            color: Theme.of(context).accentColor,
                            textColor: FlavorConfig.values.buttonTextColor,
                            shape: StadiumBorder(),
                          ),
                        )),
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
