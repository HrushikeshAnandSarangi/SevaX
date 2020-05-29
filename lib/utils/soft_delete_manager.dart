import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/utils.dart';

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

Future<bool> checkExistingRequest({
  String associatedId,
}) async {
  return await Firestore.instance
      .collection("softDeleteRequests")
      .where('requestStatus', isEqualTo: 'REQUESTED')
      .where('associatedId', isEqualTo: associatedId)
      .getDocuments()
      .then(
    (onValue) {
      return onValue.documents.length > 0;
    },
  ).catchError((onError) {
    return false;
  });
}

Future<void> showAdvisoryBeforeDeletion({
  BuildContext context,
  SoftDelete softDeleteType,
  String associatedId,
  String email,
  String associatedContentTitle,
  bool isAccedentalDeleteEnabled,
}) async {
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

  progressDialog.show();
  var isAlreadyRequested = await checkExistingRequest(
    associatedId: associatedId,
  );
  progressDialog.hide();

  if (isAlreadyRequested) {
    print("Already registered");
    _showRequestProcessingWithStatus(context: context);
    return;
  }

  if (softDeleteType == SoftDelete.REQUEST_DELETE_GROUP ||
      softDeleteType == SoftDelete.REQUEST_DELETE_TIMEBANK) {
    if (isAccedentalDeleteEnabled) {
      _showAccedentalDeleteConfirmation(
        context: context,
        softDeleteType: softDeleteType,
      );
      return;
    }
  }

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
                // MAKE REQUEST FOR SOFT DELETION//
                await registerSoftDeleteRequestFor(
                  softDeleteRequest: SoftDeleteRequest.createRequest(
                    associatedId: associatedId,
                    requestType: _getModelType(softDeleteType),
                  ),
                  softDeleteType: softDeleteType,
                ).commit();

                //SEND EMAIL TO SEVA TEAM IN CASE TIMEBANK DELETION REQUEST IS MADE
                if (softDeleteType == SoftDelete.REQUEST_DELETE_TIMEBANK) {
                  await sendMailToSevaTeam(
                    associatedContentTitle: associatedContentTitle,
                    associatedId: associatedId,
                    senderEmail: email,
                    softDeleteType: softDeleteType,
                  );
                }

                progressDialog.hide();

                showFinalResultConfirmation(
                  context,
                  softDeleteType,
                  associatedId,
                  true,
                );
              } catch (_) {
                print("Failed sending request due to ${_.toString()}");
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

Future<bool> sendMailToSevaTeam({
  String senderEmail,
  SoftDelete softDeleteType,
  String associatedContentTitle,
  String associatedId,
}) async {
  return await SevaMailer.createAndSendEmail(
      mailContent: MailContent.createMail(
    mailSender: senderEmail,
    mailReciever: "burhan@uipep.com",
    mailSubject:
        "Deletion request for ${_getModelType(softDeleteType)} $associatedContentTitle by " +
            senderEmail +
            ".",
    mailContent: senderEmail +
        " has requested to delete ${_getModelType(softDeleteType)} $associatedContentTitle with unique-identity as $associatedId.",
  ));
}

class SoftDeleteRequest extends DataModel {
  String id;
  String timestamp;
  String requestStatus;

  final String associatedId;
  final String requestType;

  SoftDeleteRequest.createRequest({
    this.associatedId,
    this.requestType,
  }) {
    id = Utils.getUuid();
    requestStatus = "REQUESTED";
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = HashMap();
    map['associatedId'] = this.associatedId ?? "NA";
    map['requestStatus'] = this.requestStatus ?? "NA";
    map['requestType'] = this.requestType ?? "NA";
    map['id'] = this.id;
    map['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    return map;
  }
}

WriteBatch registerSoftDeleteRequestFor({
  @required SoftDeleteRequest softDeleteRequest,
  @required SoftDelete softDeleteType,
}) {
  WriteBatch batch = Firestore.instance.batch();
  var registerRequestRef = Firestore.instance
      .collection("softDeleteRequests")
      .document(softDeleteRequest.id);

  var associatedEntity = Firestore.instance
      .collection(_getType(softDeleteType))
      .document(softDeleteRequest.associatedId);
  batch.setData(registerRequestRef, softDeleteRequest.toMap());
  batch.updateData(associatedEntity, {'requestedSoftDelete': true});

  return batch;
}

String _getType(SoftDelete softDeleteType) {
  switch (softDeleteType) {
    case SoftDelete.REQUEST_DELETE_TIMEBANK:
    case SoftDelete.REQUEST_DELETE_GROUP:
      return "timebanknew";

    case SoftDelete.REQUEST_DELETE_PROJECT:
      return "projects";

    default:
      return "NA";
  }
}

void _showAccedentalDeleteConfirmation({
  BuildContext context,
  SoftDelete softDeleteType,
}) {
  showDialog(
    context: context,
    builder: (BuildContext accedentalDialogContext) {
      return AlertDialog(
        title: Text(
          "Accendetal Deletion enabled",
        ),
        content: Text(
            "This timebank has \"Prevent Accidental Delete\" enabled. Please uncheck that box (in the \"Manage\" tab) before attempting to delete the ${_getType(softDeleteType)}."),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(accedentalDialogContext);
            },
            child: Text("  Dismiss  "),
          ),
        ],
      );
    },
  );
}

void _showRequestProcessingWithStatus({BuildContext context}) {
  showDialog(
    context: context,
    builder: (BuildContext _showRequestProcessingWithStatusContext) {
      return AlertDialog(
        title: Text(
          "Your request for deletion is being processed.",
        ),
        content: Text(
            "Your request to delete has been received by us. We are processing the request. You will be notified once it is completed."),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(_showRequestProcessingWithStatusContext);
            },
            child: Text("  Dismiss  "),
          ),
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
          didSuceed ? getSuccessMessage(softDeleteType) : failureMessage,
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

String getSuccessMessage(SoftDelete softDeleteType) {
  return "We have received your request to delete this ${_getModelType(softDeleteType)}. We are sorry to see you go. We will examine your request and (in some cases) get in touch with you offline before we process the deletion of the ${_getModelType(softDeleteType)}";
}
