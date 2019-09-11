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
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'Bio',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Your Bio and any #hashtags',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 20,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Please enter a Bio and any #hashtags';
                  }
                  this.bio = value;
                },
              ),
            ),
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
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    widget.onSave(bio);
                  }
                },
                child: Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//// Create a Form Widget
//class BioForm extends StatefulWidget {
//  @override
//  BioFormState createState() {
//    return BioFormState();
//  }
//}
//
//// Create a corresponding State class. This class will hold the data related to
//// the form.
//class BioFormState extends State<BioForm> {
//  // Create a global key that will uniquely identify the Form widget and allow
//  // us to validate the form
//  //
//  // Note: This is a GlobalKey<FormState>, not a GlobalKey<BioFormState>!
//  final _formKey = GlobalKey<FormState>();
//  _setPreferences() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setString('bio', globals.bio);
//  }
//
//  void _updateBioToDB() {
//    Firestore.instance.collection('users').document(globals.email).updateData({
//      'bio': globals.bio,
//    });
//    _setPreferences();
//    Navigator.pushReplacement(context,
//        MaterialPageRoute(builder: (BuildContext context) => CoreView()));
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // Build a Form widget using the _formKey we created above
//    return Container(
//        padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
//        child: SingleChildScrollView(
//          child: Form(
//            key: _formKey,
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Container(
//                  padding: EdgeInsets.only(bottom: 40.0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      FlatButton(
//                        onPressed: () {
//                          // _updateOnSkip();
//                          Navigator.pushReplacement(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (BuildContext context) =>
//                                      CoreView()));
//                        },
//                        child: Text('Skip',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w500, fontSize: 18.0)),
//                      ),
//                      FlatButton(
//                        onPressed: () {
//                          if (_formKey.currentState.validate()) {
//                            // If the form is valid, we want to show a Snackbar
//                            Scaffold.of(context).showSnackBar(
//                                SnackBar(content: Text('Processing Data')));
//                            _updateBioToDB();
//                            Navigator.pushReplacement(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (BuildContext context) =>
//                                        CoreView()));
//                          }
//                        },
//                        child: Text('Next',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w500, fontSize: 18.0)),
//                      ),
//                    ],
//                  ),
//                ),
//                TextFormField(
//                  style: TextStyle(fontSize: 18.0, color: Colors.black87),
//                  decoration: InputDecoration(
//                      hintText: 'Your Bio and any #hashtages',
//                      border: InputBorder.none),
//                  keyboardType: TextInputType.multiline,
//                  maxLines: 20,
//                  validator: (value) {
//                    if (value.isEmpty) {
//                      return 'Please enter a Bio and any #hashtages';
//                    }
//                    globals.bio = value;
//                  },
//                ),
//              ],
//            ),
//          ),
//        ));
//  }
//}
