import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/user_info/pages/interests.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;

class BioPage extends StatefulWidget {
  final UserModel user;

  const BioPage({Key key, this.user}) : super(key: key);

  @override
  _BioViewState createState() => _BioViewState();
}

class _BioViewState extends State<BioPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OutlineInputBorder textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0x0FFC7C7CC)),
  );
  String bio = '';
  UserModel user;
  final FocusNode _nodeText1 = FocusNode();

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => InterestPage(user: user),
            ),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.5,
            title: Text(
              AppLocalizations.of(context).translate('bio', 'title'),
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, top: 0.0, bottom: 10.0),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('bio', 'description'),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          KeyboardActions(
                              tapOutsideToDismiss: true,
                              config: KeyboardActionsConfig(
                                keyboardSeparatorColor: Colors.grey[300],
                                actions: [
                                  KeyboardActionsItem(
                                    focusNode: _nodeText1,
                                  )
                                ],
                              ),
                              child: TextFormField(
                                focusNode: _nodeText1,
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black54),
                                decoration: InputDecoration(
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  hintText: AppLocalizations.of(context)
                                      .translate('bio', 'hint_biotext'),
                                  border: textFieldBorder,
                                  enabledBorder: textFieldBorder,
                                  focusedBorder: textFieldBorder,
                                ),
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 6,
                                maxLines: 50,
                                maxLength: 500,
                                validator: (value) {
                                  if (value.trim().isEmpty) {
                                    return AppLocalizations.of(context)
                                        .translate('bio', 'motiviation_text');
                                  }
                                  if (value.length < 50) {
                                    this.bio = value;
                                    return AppLocalizations.of(context)
                                        .translate('bio', 'min_char_limit');
                                  }
                                  this.bio = value;
                                },
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: 134,
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      user.bio = bio;
                      fireStoreManager.updateUser(user: user).then((_) {
                        // customRouter(context: context, user: user);
                      }).catchError((e) => print(e));
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('shared', 'next'),
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  AppConfig.prefs.setBool(AppConfig.skip_bio, true);
                  // customRouter(context: context, user: user);
                },
                child: Text(
                  AppConfig.prefs.getBool(AppConfig.skip_bio) == null
                      ? AppLocalizations.of(context).translate('shared', 'skip')
                      : AppLocalizations.of(context)
                          .translate('shared', 'capital_cancel'),
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
