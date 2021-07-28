import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/widgets/custom_buttons.dart';

//BuildContext buildContext;
Future<void> fetchLinkData() async {
  // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
  var link = await FirebaseDynamicLinks.instance
      .getInitialLink()
      .then((link) {
        return link;
      })
      .whenComplete(() {})
      .onError((error, stackTrace) {});

  // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
  await handleLinkData(data: link);
  FirebaseDynamicLinks.instance.onLink(
      onError: (_) async {},
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        return handleLinkData(
          data: dynamicLink,
        );
      });

  // This will handle incoming links if the application is already opened
}

Future<void> fetchBulkInviteLinkData(BuildContext context) async {
  // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
  var link = await FirebaseDynamicLinks.instance.getInitialLink();
  //buildContext = context;
  // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
  await handleLinkData(data: link);
  FirebaseDynamicLinks.instance.onLink(
      onError: (_) async {},
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        return handleBulkInviteLinkData(data: dynamicLink, context: context);
      });

  // This will handle incoming links if the application is already opened
}

Future<bool> handleLinkData(
    {PendingDynamicLinkData data, BuildContext context}) async {
  final Uri uri = data?.link;
  if (uri != null) {
    final queryParams = uri.queryParameters;
    if (queryParams.length > 0) {
      String invitedMemberEmail = queryParams["invitedMemberEmail"];
      String communityId = queryParams["communityId"];
      String primaryTimebankId = queryParams["primaryTimebankId"];

      var firebaseUserCred = await FirebaseAuth.instance.currentUser;

      UserModel localUser = await _getSignedInUserDocs(
        userId: firebaseUserCred.uid,
      );

      return await registerloggedInUserToCommunity(
        communityId: communityId,
        loggedInUser: localUser,
        invitedMemberEmail: invitedMemberEmail,
        primaryTimebankId: primaryTimebankId,
        adminCredentials: firebaseUserCred,
      ).then((onValue) {
        return true;
      }).catchError((onError) {
        return false;
      });
    }
  } else {}
  return false;
}

Future<bool> handleBulkInviteLinkData(
    {PendingDynamicLinkData data, BuildContext context}) async {
  final Uri uri = data?.link;
  if (uri != null) {
    final queryParams = uri.queryParameters;
    if (queryParams.length > 0) {
      String invitedMemberEmail = queryParams["invitedMemberEmail"];
      String communityId = queryParams["communityId"];
      String primaryTimebankId = queryParams["primaryTimebankId"];
      if (queryParams.containsKey("isFromBulkInvite") &&
          queryParams["isFromBulkInvite"] == 'true') {
        resetPassword(invitedMemberEmail, context);
      }
    }
  }
  return false;
}

Future<UserModel> _getSignedInUserDocs({String userId}) async {
  UserModel userModel = await fireStoreManager.getUserForId(
    sevaUserId: userId,
  );
  return userModel;
}

Future<bool> registerloggedInUserToCommunity({
  UserModel loggedInUser,
  String communityId,
  String invitedMemberEmail,
  String primaryTimebankId,
  User adminCredentials,
}) async {
  log("=====Inside fetchLinkData registerloggedInUserToCommunity");
  if (loggedInUser.email != invitedMemberEmail) {
    log("=====Inside fetchLinkData === loggedInUser.email != invitedMemberEmail");
    return false;
  }

  if (loggedInUser.communities != null &&
      loggedInUser.communities.contains(communityId)) {
    log("loggedInUser.communities != null && loggedInUser.communities.contains(communityId)");
    return false;
  } else {
    log("Inside fetchLinkData cid -> " +
        communityId +
        " " +
        loggedInUser.sevaUserID +
        " " +
        loggedInUser.email +
        " " +
        loggedInUser.fullname +
        " " +
        loggedInUser.photoURL +
        " " +
        primaryTimebankId);

    return await initRegisterationMemberToCommunity(
      communityId: communityId,
      memberJoiningSevaUserId: loggedInUser.sevaUserID,
      newMemberJoinedEmail: loggedInUser.email,
      newMemberFullName: loggedInUser.fullname,
      newMemberPhotoUrl: loggedInUser.photoURL,
      primaryTimebankId: primaryTimebankId,
      adminCredentials: adminCredentials,
    ).then((onValue) => true).catchError((onError) => false);
  }
}

Future<bool> initRegisterationMemberToCommunity({
  @required String communityId,
  @required String primaryTimebankId,
  @required String memberJoiningSevaUserId,
  @required String newMemberJoinedEmail,
  @required User adminCredentials,
  @required String newMemberFullName,
  @required String newMemberPhotoUrl,
}) async {
  return await InvitationManager.registerMemberToCommunity(
    communityId: communityId,
    memberJoiningSevaUserId: memberJoiningSevaUserId,
    newMemberJoinedEmail: newMemberJoinedEmail,
    primaryTimebankId: primaryTimebankId,
    adminCredentials: adminCredentials,
    newMemberFullName: newMemberFullName,
    newMemberPhotoUrl: newMemberPhotoUrl,
  ).then((onValue) => true).catchError((onError) => false);
}

Future<void> resetPassword(String email, BuildContext mContext) async {
  await FirebaseAuth.instance
      .sendPasswordResetEmail(email: email)
      .then((onValue) {
    showDialog<AlertDialog>(
      context: mContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).reset_password),
          content: Container(
            height: MediaQuery.of(mContext).size.height / 10,
            width: MediaQuery.of(mContext).size.width / 12,
            child: Text(
              S.of(context).reset_password_message,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(
                S.of(context).close,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

//    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//      content: Text(AppLocalizations.of(context)
//          .translate('login', 'reset_link_message')),
//      action: SnackBarAction(
//        label: AppLocalizations.of(context).translate('shared', 'dismiss'),
//        onPressed: () {
//          ScaffoldMessenger.of(context).hideCurrentSnackBar();
//        },
//      ),
//    ));
  });
}
