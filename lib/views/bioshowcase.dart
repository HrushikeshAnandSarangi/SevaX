import 'package:flutter/material.dart';
import 'package:sevaexchange/views/bioedit.dart';

import 'package:sevaexchange/views/core.dart';

class BioShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Text(
              //   'Bio and Resumé',
              //   style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
              // ),
              FlatButton(
                // color: Colors.deepPurple,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BioEdit()));
                },
                child: Icon(Icons.edit),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 25.0, right: 25.0),
          child: Text(
            SevaCore.of(context).loggedInUser.bio,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
