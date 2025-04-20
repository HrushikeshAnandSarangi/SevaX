import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import 'EULAgreement.dart';

class EulaAgreement extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EulaAgreementState();
  }
}

class EulaAgreementState extends State<EulaAgreement> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _signOut(context);
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0.5,
            leading: BackButton(
              color: Colors.white,
              onPressed: () async {
                // Navigator.of(context).pop();
                await _signOut(context);
              },
            ),
            title: Text(
              S.of(context).eula_title,
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
                        EULAgreementScript.SEVA_EULA_AGREEMENT,
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
                            onChanged: (bool? value) {
                              setState(() {
                                userAcceptanceStatus = value ?? false;
                              });
                            },
                            value: userAcceptanceStatus,
                          ),
                          Expanded(
                            child: Text(
                              S.of(context).eula_delcaration,
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
                          child: CustomElevatedButton(
                            onPressed: userAcceptanceStatus
                                ? () {
                                    Navigator.pop(
                                        context, {'response': 'ACCEPTED'});
                                  }
                                : () {},
                            child: Text(
                              S.of(context).proceed,
                              style:
                                  Theme.of(context).primaryTextTheme.labelLarge,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                            textColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2.0,
                          )),
                      SizedBox(height: 20),
                    ],
                  )),
            ],
          )),
    );
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
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AuthRouter(),
          ),
          (Route<dynamic> route) => false);
    });
  }
}
