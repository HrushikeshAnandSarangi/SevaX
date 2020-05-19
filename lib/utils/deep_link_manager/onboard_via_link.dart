import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;

Future<void> fetchLinkData() async {
  // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
  var link = await FirebaseDynamicLinks.instance.getInitialLink();

  // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
  await handleLinkData(data: link);
  FirebaseDynamicLinks.instance.onLink(onError: (_) async {
    print("Error!!!");
  }, onSuccess: (PendingDynamicLinkData dynamicLink) async {
    return handleLinkData(data: dynamicLink);
  });

  // This will handle incoming links if the application is already opened
}

Future<bool> handleLinkData({PendingDynamicLinkData data}) async {
  final Uri uri = data?.link;
  if (uri != null) {
    final queryParams = uri.queryParameters;
    if (queryParams.length > 0) {
      String invitedMemberEmail = queryParams["invitedMemberEmail"];
      String communityId = queryParams["communityId"];
      String primaryTimebankId = queryParams["primaryTimebankId"];

      var firebaseUserCred = await FirebaseAuth.instance.currentUser();

      UserModel localUser = await _getSignedInUserDocs(
        userId: firebaseUserCred.uid,
      );

      print(
          "==================================================================");
      print("===${localUser.toMap()}===");
      print(
          "==================================================================");

      return await registerloggedInUserToCommunity(
        communityId: communityId,
        loggedInUser: localUser,
        invitedMemberEmail: invitedMemberEmail,
        primaryTimebankId: primaryTimebankId,
      ).then((onValue) => true).catchError((onError) => false);
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
}) async {
  if (loggedInUser.email != invitedMemberEmail) {
    print("Member is a not a verified member from link.");
    return false;
  }

  if (loggedInUser.communities != null &&
      loggedInUser.communities.contains(communityId)) {
    print("Member is a verified member and has been already registered.");
    return false;
  } else {
    print("Register this member --> ..");
    return await initRegisterationMemberToCommunity(
      communityId: communityId,
      memberJoiningSevaUserId: loggedInUser.sevaUserID,
      newMemberJoinedEmail: loggedInUser.email,
      primaryTimebankId: primaryTimebankId,
    ).then((onValue) => true).catchError((onError) => false);
  }
}

Future<bool> initRegisterationMemberToCommunity({
  @required String communityId,
  @required String primaryTimebankId,
  @required String memberJoiningSevaUserId,
  @required String newMemberJoinedEmail,
}) async {
  return await InvitationManager.registerMemberToCommunity(
    communityId: communityId,
    memberJoiningSevaUserId: memberJoiningSevaUserId,
    newMemberJoinedEmail: newMemberJoinedEmail,
    primaryTimebankId: primaryTimebankId,
  ).then((onValue) => true).catchError((onError) => false);
}
