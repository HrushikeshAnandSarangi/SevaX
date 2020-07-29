import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/utils/app_config.dart';

typedef StringCallback = void Function(String bio);

class BioView extends StatefulWidget {
  final VoidCallback onSkipped;
  final StringCallback onSave;
  final VoidCallback onBacked;

  BioView({@required this.onSkipped, @required this.onSave, this.onBacked});

  @override
  _BioViewState createState() => _BioViewState();
}

class _BioViewState extends State<BioView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OutlineInputBorder textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0x0FFC7C7CC)),
  );
  String bio = '';
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: BackButton(
              onPressed: () {
                widget.onBacked();
              },
            ),
            elevation: 0.5,
            title: Text(
              'Bio',
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
                        'Please tell us a little about yourself in a few sentences. For example, what makes you unique.',
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
                          TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                              decoration: InputDecoration(
                                fillColor: Colors.grey[300],
                                filled: true,
                                hintText: 'Tell us a little about yourself.',
                                border: textFieldBorder,
                                enabledBorder: textFieldBorder,
                                focusedBorder: textFieldBorder,
                              ),
                              keyboardType: TextInputType.multiline,
                              autovalidate: autoValidateText,
                              minLines: 6,
                              maxLines: 50,
                              maxLength: 150,
                              onChanged: (value) {
                                if (value.length > 1) {
                                  setState(() {
                                    autoValidateText = true;
                                  });
                                } else {
                                  setState(() {
                                    autoValidateText = false;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value.trim().isEmpty) {
                                  return 'It\'s easy, please fill few words about you.';
                                }
                                if (value.length < 50) {
                                  this.bio = value;
                                  return 'Min 50 characters *';
                                }
                                if (profanityDetector.isProfaneString(value)) {
                                  return AppLocalizations.of(context)
                                      .translate('profanity', 'alert');
                                }
                                this.bio = value;
                              }),
                          // Text(
                          //   '*min 100 characters',
                          //   style: TextStyle(color: Colors.red),
                          // )
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
                      widget.onSave(bio);
                    }
                  },
                  child: Text(
                    'Next',
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                  // color: Theme.of(context).accentColor,
                  // textColor: FlavorConfig.values.buttonTextColor,
                  // shape: StadiumBorder(),
                ),
              ),
              FlatButton(
                onPressed: () {
                  widget.onSkipped();
                },
                child: Text(
                  AppConfig.prefs.getBool(AppConfig.skip_bio) == null
                      ? 'Skip'
                      : 'Cancel',
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
