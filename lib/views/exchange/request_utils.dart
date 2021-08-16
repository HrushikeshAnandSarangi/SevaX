import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/helpers/projects_helper.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

void updateExitWithConfirmationValue(BuildContext context, int index, String value) {
  ExitWithConfirmation.of(context).fieldValues[index] = value;
}

Future createProjectOneToManyRequest({context, projectModel, requestModel, createEvent}) async {
  //Create new Event/Project for ONE TO MANY Request
  if (projectModel == null &&
      createEvent &&
      requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
    String newProjectId = Utils.getUuid();
    requestModel.projectId = newProjectId;
    List<String> pendingRequests = [requestModel.selectedInstructor.email];

    ProjectModel newProjectModel = ProjectModel(
      emailId: requestModel.email,
      members: [],
      communityName: requestModel.communityName,
      //phoneNumber:,
      address: requestModel.address,
      timebanksPosted: [requestModel.timebankId],
      id: newProjectId,
      name: requestModel.title,
      communityId: requestModel.communityId,
      photoUrl: requestModel.photoUrl,
      creatorId: requestModel.sevaUserId,
      mode: ProjectMode.TIMEBANK_PROJECT,
      timebankId: requestModel.timebankId,
      associatedMessaginfRoomId: '',
      requestedSoftDelete: false,
      softDelete: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      pendingRequests: pendingRequests,
      startTime: requestModel.requestStart,
      endTime: requestModel.requestEnd,
      description: requestModel.description,
    );

    await createProject(projectModel: newProjectModel);

    log("======================== createProjectWithMessaging()");
    await ProjectMessagingRoomHelper.createProjectWithMessagingOneToManyRequest(
      projectModel: newProjectModel,
      projectCreator: SevaCore.of(context).loggedInUser,
    );
  }
}

Widget optionRadioButton<T>({
  String title,
  T value,
  T groupvalue,
  Function onChanged,
  bool isEnabled = true,
}) {
  return ListTile(
    key: UniqueKey(),
    contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
    title: Text(title),
    leading: Radio<T>(
      value: value,
      groupValue: groupvalue,
      onChanged: (isEnabled ?? true) ? onChanged : null,
    ),
  );
}

void showInsufficientBalance(double credits, BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          title: Text(
              S.of(context).insufficientSevaCreditsDialog.replaceFirst('***', credits.toString())),
          actions: <Widget>[
            CustomTextButton(
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () async {
                Navigator.of(viewContext).pop();
              },
            ),
          ],
        );
      });
}

void showDialogForTitle({String dialogTitle, BuildContext context}) async {
  showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          title: Text(dialogTitle),
          actions: <Widget>[
            CustomTextButton(
              shape: StadiumBorder(),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(viewContext).pop();
              },
            ),
          ],
        );
      });
}

TextStyle hintTextStyle = TextStyle(
  fontSize: 14,
  // fontWeight: FontWeight.bold,
  color: Colors.grey,
  fontFamily: 'Europa',
);
