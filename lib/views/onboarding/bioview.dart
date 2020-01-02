import 'package:flutter/material.dart';

import '../../flavor_config.dart';

typedef StringCallback = void Function(String bio);

class BioView extends StatefulWidget {
  final VoidCallback onSkipped;
  final StringCallback onSave;

  BioView({
    @required this.onSkipped,
    @required this.onSave,
  });

  @override
  _BioViewState createState() => _BioViewState();
}

class _BioViewState extends State<BioView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String bio = '';

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
            elevation: 0.5,
            backgroundColor: Color(0xFFFFFFFF),
            leading: BackButton(color: Colors.black54),
            title: Text(
              'Bio',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(top: 20.0, left: 16.0, right: 25.0),
            child: ListView(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 10.0),
                  child: Text(
                    'Share with the community about you that highlights what makes you special',
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  )),
              Form(
                key: _formKey,
                child: TextFormField(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'What would you like to tell about you?',
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 6,
                  maxLines: 50,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return 'Its easy, please fill few words about you.';
                    }
                    this.bio = value;
                  },
                ),
              )
            ]),
          ),
          bottomNavigationBar: ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  widget.onSkipped();
                },
                child: Text('Skip'),
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    widget.onSave(bio);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text('Next'),
                    ),
                  ],
                ),
                color: Theme.of(context).accentColor,
                textColor: FlavorConfig.values.buttonTextColor,
                shape: StadiumBorder(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}