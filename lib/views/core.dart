import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class SevaCore extends InheritedWidget {
  UserModel loggedInUser;

  SevaCore({
    required this.loggedInUser,
    required Widget child,
    Key? key,
  })  : assert(loggedInUser != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(SevaCore oldWidget) {
    return loggedInUser != oldWidget.loggedInUser;
  }

  static SevaCore of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SevaCore>()!;
  }

  Future<bool> get _checkInternet async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<Widget> errorDialogueBox(BuildContext context) async {
    var status = await _checkInternet;
    if (status) {
      return Container(); // Return an empty widget instead of null
    }
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Icon(
              Icons.warning,
              color: Colors.red,
              size: 30,
            ),
          ),
          Text(
            S.of(context).internet_connection_lost,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          SizedBox(width: 10),
          CustomTextButton(
            color: Colors.yellow,
            child: Text(
              S.of(context).ok,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
