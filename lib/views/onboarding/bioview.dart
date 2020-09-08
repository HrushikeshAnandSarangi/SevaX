import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

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
  final _focusNodeBio = FocusNode();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              S.of(context).bio,
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
                        S.of(context).bio_description,
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            height: 250,
                            child: KeyboardActions(
                              tapOutsideToDismiss: true,
                              config: KeyboardActionsConfig(
                                keyboardSeparatorColor: Color(0x0FF766FE0),
                                actions: [
                                  KeyboardActionsItem(
                                    focusNode: _focusNodeBio,
                                  )
                                ],
                              ),
                              child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.black54),
                            decoration: InputDecoration(
                              errorMaxLines: 2,
                              fillColor: Colors.grey[300],
                              filled: true,
                              hintText: S.of(context).bio_hint,
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
                              if (value.length > 1 && !autoValidateText) {
                                setState(() {
                                  autoValidateText = true;
                                });
                              }
                              if (value.length <= 1 && autoValidateText) {
                                setState(() {
                                  autoValidateText = false;
                                });
                              }
                            },
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return S.of(context).validation_error_bio_empty;
                              }
                              if (value.length < 50) {
                                this.bio = value;
                                return S
                                    .of(context)
                                    .validation_error_bio_min_characters;
                              }
                              if (profanityDetector.isProfaneString(value)) {
                                return S.of(context).profanity_text_alert;
                              }
                              this.bio = value;
                              return null;
                            })))
                          ),
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
                    AppLocalizations.of(context).translate('shared', 'next'),
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
