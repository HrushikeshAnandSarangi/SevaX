import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/utils.dart';

import '../flavor_config.dart';

String failureMessage =
    "Sending request failed somehow, please try again later!";

String successTitle = "Request submitted";
String failureTitle = "Request failed!";
String reason = "";
final GlobalKey<FormState> _formKey = GlobalKey();

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
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;
  progressDialog = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: false,
  );

  progressDialog.show();
  var isAlreadyRequested = await checkExistingRequest(
    associatedId: associatedId,
  );
  progressDialog.hide();

  if (isAlreadyRequested) {
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
          S.of(context).delete_confirmation + associatedContentTitle + "?",
          style: TextStyle(fontSize: 17),
        ),
        content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getContentFromType(softDeleteType, context),
                    style: TextStyle(fontSize: 15),
                  ),
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      hintText: S.of(context).enter_reason_to_delete,
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(fontSize: 17.0),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    autovalidate: autoValidateText,
                    onChanged: (value) {
                      if (value.length > 1) {
                        autoValidateText = true;
                      } else {
                        autoValidateText = false;
                      }
                      print("auto $autoValidateText");
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return S.of(context).enter_reason_to_delete_error;
                      } else if (profanityDetector.isProfaneString(value)) {
                        return S.of(context).profanity_text_alert;
                      } else {
                        reason = value;
                        return null;
                      }
                    },
                  ),
                ],
              ),
            )),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(contextDialog);
            },
            child: Text(
              S.of(context).cancel,
            ),
          ),
          FlatButton(
            color: Colors.white,
            onPressed: () async {
              if (!_formKey.currentState.validate()) {
                return;
              }
              Navigator.pop(contextDialog);
              progressDialog.show();
              try {
                // MAKE REQUEST FOR SOFT DELETION//
                await registerSoftDeleteRequestFor(
                  softDeleteRequest: SoftDeleteRequest.createRequest(
                    associatedId: associatedId,
                    requestType: _getModelType(softDeleteType),
                    reason: reason,
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
                ).then((_) {
                  Navigator.of(context).pop();
                });
                ;
              } catch (_) {
                print("Failed sending request due to ${_.toString()}");
                progressDialog.hide();
                showFinalResultConfirmation(
                  context,
                  softDeleteType,
                  associatedId,
                  false,
                ).then((_) {
                  Navigator.of(context).pop();
                });
              }
            },
            child: Text(
              S.of(context).delete + " " + associatedContentTitle,
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
    mailReciever: "delete-timebank@sevaexchange.com",
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
  String reason;

  final String associatedId;
  final String requestType;

  SoftDeleteRequest.createRequest(
      {this.associatedId, this.requestType, this.reason}) {
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
    map['reason'] = this.reason;
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
          S.of(context).accidental_delete_enabled,
        ),
        content: Text(
          S.of(context).accidental_delete_enabled_description.replaceAll(
                "**",
                _getModelType(softDeleteType),
              ),
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(accedentalDialogContext);
            },
            child: Text(
              S.of(context).dismiss,
            ),
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
          S.of(context).deletion_request_being_processed,
        ),
        content: Text(
          S.of(context).deletion_request_progress_description,
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(_showRequestProcessingWithStatusContext);
            },
            child: Text(
              S.of(context).dismiss,
            ),
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
        title: Text(
          S.of(context).submitting_request,
        ),
        content: LinearProgressIndicator(),
      );
    },
  );
}

String _getContentFromType(
  SoftDelete type,
  BuildContext context,
) {
  switch (type) {
    case SoftDelete.REQUEST_DELETE_GROUP:
      return S.of(context).advisory_for_timebank;
    case SoftDelete.REQUEST_DELETE_PROJECT:
      return S.of(context).advisory_for_projects;
    case SoftDelete.REQUEST_DELETE_TIMEBANK:
      return S.of(context).advisory_for_timebank;
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

Future<bool> showFinalResultConfirmation(
  BuildContext context,
  SoftDelete softDeleteType,
  String associatedId,
  bool didSuceed,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          didSuceed
              ? S.of(context).request_submitted
              : S.of(context).request_failed,
        ),
        content: Text(
          didSuceed
              ? getSuccessMessage(softDeleteType, context)
              : S.of(context).request_failure_message,
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: () async {
              await Future.delayed(Duration(milliseconds: 800), () {
                Navigator.pop(context);
//                Navigator.of(context).push(
//                  MaterialPageRoute(
//                    builder: (context) => SevaCore(
//                      loggedInUser: SevaCore.of(context).loggedInUser,
//                      child: HomePageRouter(),
//                    ),
//                  ),
//                );
              });
//              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                S.of(context).dismiss,
              ),
            ),
          ),
        ],
      );
    },
  );
  return true;
}

String getSuccessMessage(
  SoftDelete softDeleteType,
  BuildContext context,
) {
  return S
      .of(context)
      .deletion_request_recieved
      .replaceAll('***', _getModelType(softDeleteType));
}

Future<String> showProfanityImageAlert({BuildContext context, String content}) {
  return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: Text(S.of(context).profanity_alert),
          content: Text(
            S.of(context).profanity_image_alert + ' ' + content,
          ),
          actions: <Widget>[
            FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.pop(_context, 'Proceed');
              },
            ),
          ],
        );
      });
}

Future<void> showFailedLoadImage({
  BuildContext context,
}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: Text(S.of(context).failed_load_image_title),
          content: Text(
            S.of(context).failed_load_image,
          ),
          actions: <Widget>[
            FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.pop(_context);
              },
            ),
          ],
        );
      });
}

Future<ProfanityStatusModel> getProfanityStatus(
    {ProfanityImageModel profanityImageModel}) async {
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();

  if (profanityImageModel.adult == ProfanityStrings.veryLikely ||
      profanityImageModel.adult == ProfanityStrings.likely) {
    profanityStatusModel.isProfane = true;
    profanityStatusModel.category = ProfanityStrings.adult;
  } else if (profanityImageModel.spoof == ProfanityStrings.veryLikely ||
      profanityImageModel.spoof == ProfanityStrings.likely) {
    profanityStatusModel.isProfane = true;
    profanityStatusModel.category = ProfanityStrings.spoof;
  } else if (profanityImageModel.medical == ProfanityStrings.veryLikely ||
      profanityImageModel.medical == ProfanityStrings.likely) {
    profanityStatusModel.isProfane = true;
    profanityStatusModel.category = ProfanityStrings.medical;
  } else if (profanityImageModel.racy == ProfanityStrings.veryLikely ||
      profanityImageModel.racy == ProfanityStrings.likely) {
    profanityStatusModel.isProfane = true;
    profanityStatusModel.category = ProfanityStrings.racy;
  } else if (profanityImageModel.violence == ProfanityStrings.veryLikely ||
      profanityImageModel.violence == ProfanityStrings.likely) {
    profanityStatusModel.isProfane = true;
    profanityStatusModel.category = ProfanityStrings.violence;
  } else {
    profanityStatusModel.isProfane = false;
  }

  return profanityStatusModel;
}
