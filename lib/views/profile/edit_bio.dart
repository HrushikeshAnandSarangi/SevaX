import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/views/core.dart';

class EditBio extends StatefulWidget {
  String existingBio;
  EditBio(String existingBio) {
    this.existingBio = existingBio;
  }

  @override
  _EditBioState createState() => _EditBioState();
}

class _EditBioState extends State<EditBio> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var bioController = TextEditingController();
  String bio = '';
  initState() {
    super.initState();
    // Add listeners to this class
    print('Bio default value --> ${widget.existingBio}');
    bioController.text = widget.existingBio;
  }

  @override
  Widget build(BuildContext context) {
    // String bio = SevaCore.of(context).loggedInUser.bio;

    // bioController.text = bio;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'Edit Bio',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: bioController,
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Your Bio ',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 20,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Please enter a Bio';
                  }
                  bio = value;
                },
              ),
            ),
          ),
          bottomNavigationBar: ButtonBar(
            children: <Widget>[
              RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    // updateUserData(SevaCore.of(context).loggedInUser);

                    setState(() {
                      SevaCore.of(context).loggedInUser.bio = bio;
                    });
                    print(
                        "Update Bui to -> ${SevaCore.of(context).loggedInUser.bio}");

                    Firestore.instance
                        .collection("users")
                        .document(SevaCore.of(context).loggedInUser.email)
                        .updateData({'bio': bio}).then((onValue) {
                      print("Updated Bio");
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: Text(
                  'Update Bio',
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
