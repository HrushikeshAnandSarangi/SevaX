import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import '../flavor_config.dart';

String successMessages =
    "We have received your request to delete this Timebank. We are sorry to see you go. We will examine your request and (in some cases) get in touch with you offline before we process the deletion of the ";
String failureMessage =
    "Sending request failed somehow, please try again later!";

String successTitle = "Request submitted";
String failureTitle = "Request failed!";

ProgressDialog progressDialog;

enum SoftDelete {
  REQUEST_DELETE_GROUP,
  REQUEST_DELETE_TIMEBANK,
  REQUEST_DELETE_PROJECT,
}

void showAdvisoryBeforeDeletion({
  BuildContext context,
  SoftDelete softDeleteType,
  String associatedId,
  String email,
  String associatedContentTitle,
}) {
  progressDialog = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: false,
    customBody: Container(
      child: Center(
        child: Text("Please wait..."),
      ),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext contextDialog) {
      return AlertDialog(
        title: Text(
          "Are your sure you want to delete " + associatedContentTitle + "?",
        ),
        content: Text(_getContentFromType(softDeleteType)),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(contextDialog);
            },
            child: Text("  Cancel  "),
          ),
          FlatButton(
            color: Colors.white,
            onPressed: () async {
              Navigator.pop(contextDialog);
              progressDialog.show();
              try {
                await http.post(
                  "${FlavorConfig.values.cloudFunctionBaseURL}/mailForSoftDelete",
                  headers: {"Content-Type": "application/json"},
                  body: json.encode(
                    {
                      "mailSender": 'app@sevaexchange.com',
                      "mailSubject":
                          "Deletion request for ${_getModelType(softDeleteType)} $associatedContentTitle by " +
                              email +
                              ".",
                      "mailBody": email +
                          " has requested to delete ${_getModelType(softDeleteType)} $associatedContentTitle with unique-identity as $associatedId.",
                    },
                  ),
                );
                progressDialog.hide();
                showFinalResultConfirmation(
                  context,
                  softDeleteType,
                  associatedId,
                  true,
                );
              } catch (_) {
                progressDialog.hide();
                showFinalResultConfirmation(
                  context,
                  softDeleteType,
                  associatedId,
                  false,
                );
              }
            },
            child: Text(
              "Delete " + associatedContentTitle,
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
    builder: (BuildContext context) {
      buildContextForLinearProgress = context;
      return AlertDialog(
        title: Text("Submitting request..."),
        content: LinearProgressIndicator(),
      );
    },
  );
}

String advisoryForTimebank =
    "All relevent information including projects, requests and offers under the group will be deleted!";
String advisoryForProjects =
    "All requests associated to this request would be removed";

String _getContentFromType(SoftDelete type) {
  switch (type) {
    case SoftDelete.REQUEST_DELETE_GROUP:
      return advisoryForTimebank;
    case SoftDelete.REQUEST_DELETE_PROJECT:
      return advisoryForProjects;
    case SoftDelete.REQUEST_DELETE_TIMEBANK:
      return advisoryForTimebank;
  }
}

String _getModelType(SoftDelete type) {
  switch (type) {
    case SoftDelete.REQUEST_DELETE_GROUP:
      return "group";
    case SoftDelete.REQUEST_DELETE_PROJECT:
      return "project";
    case SoftDelete.REQUEST_DELETE_TIMEBANK:
      return "timebank";
  }
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
          didSuceed
              ? successMessages + _getModelType(softDeleteType) + "."
              : failureMessage,
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Text("Dismiss"),
            ),
          ),
        ],
      );
    },
  );
}
