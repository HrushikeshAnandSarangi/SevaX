import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String successMessages =
    "A request has been successfully submited by SevaX admin, you will notified with youor registered mail. ";
String failureMessage =
    "Sending request failed somehow, please try again later!";

String successTitle = "Request submitted";
String failureTitle = "Request failed!";

enum SoftDelete {
  REQUEST_DELETE_GROUP,
  REQUEST_DELETE_TIMEBANK,
  REQUEST_DELETE_PROJECT,
}

void showAdvisoryBeforeDeletion(
  BuildContext context,
  SoftDelete softDeleteType,
  String associatedId,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Are your sure"),
        content: Text(
            "All relevent information including projects, requests and offers under the group will be deleted!"),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("  Cancel  "),
          ),
          FlatButton(
            color: Colors.white,
            onPressed: () async {
              Navigator.pop(context);
              showLinearProgress(context: context);

              try {
                await http.get("https://gitlab.com/sevaexchange/seva-exchange");
                Navigator.pop(buildContextForLinearProgress);
                // showFinalResultConfirmation(
                //   context,
                //   softDeleteType,
                //   associatedId,
                //   false,
                // );
              } catch (_) {
                Navigator.pop(buildContextForLinearProgress);

                // showFinalResultConfirmation(
                //   context,
                //   softDeleteType,
                //   associatedId,
                //   false,
                // );
              }
            },
            child: Text(
              "DELETE",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          )
        ],
      );
    },
  );
}

BuildContext buildContextForLinearProgress;

void showLinearProgress({BuildContext context}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogForLinearProgress) {
      buildContextForLinearProgress = context;
      return AlertDialog(
        title: Text("Submitting request..."),
        content: LinearProgressIndicator(),
      );
    },
  );
}

void showFinalResultConfirmation(
  BuildContext context,
  SoftDelete softDeleteType,
  String associatedId,
  bool didSuceed,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          didSuceed ? successTitle : failureTitle,
        ),
        content: Text(
          didSuceed ? successMessages : failureMessage,
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Dismiss"),
          ),
        ],
      );
    },
  );
}
