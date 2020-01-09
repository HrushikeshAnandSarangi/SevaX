import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/views/core.dart';

class EditName extends StatefulWidget {
  String existingFullName;
  EditName(String existingFullName) {
    this.existingFullName = existingFullName;
  }
  @override
  _EditNameState createState() => _EditNameState();
}

class _EditNameState extends State<EditName> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var fullnameController = TextEditingController();
  String fullname = ' ';

  void initState() {
    super.initState();
    fullnameController.text = widget.existingFullName;
  }

  @override
  Widget build(BuildContext context) {
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
              'Edit name',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: fullnameController,
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Your name ',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 20,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  fullname = value;
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
                    setState(() {
                      SevaCore.of(context).loggedInUser.fullname = fullname;
                    });
                    Firestore.instance
                        .collection("users")
                        .document(SevaCore.of(context).loggedInUser.email)
                        .updateData({'fullname': fullname}).then((onValue) {
                      // print("Updated fullname to ${fullname}");
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: Text(
                  'Update name',
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
