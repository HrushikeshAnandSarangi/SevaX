import 'package:flutter/material.dart';

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
  final OutlineInputBorder textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0x0FFC7C7CC)),
  );
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
            title: Text(
              'Bio',
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 90,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, top: 0.0, bottom: 10.0),
                          child: Text(
                            'Please tell us a little about yourself in a few sentences. For example, what makes you unique.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black87),
                                decoration: InputDecoration(
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  hintText: 'Tell us a little about yourself.',
                                  border: textFieldBorder,
                                  enabledBorder: textFieldBorder,
                                  focusedBorder: textFieldBorder,
                                ),
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 6,
                                maxLines: 50,
                                maxLength: 150,
                                validator: (value) {
                                  if (value.trim().isEmpty) {
                                    return 'Its easy, please fill few words about you.';
                                  }
                                  if (value.length < 50)
                                    return '* min 50 characters';
                                  this.bio = value;
                                },
                              ),
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
                      'Skip',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
