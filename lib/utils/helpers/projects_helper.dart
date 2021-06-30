import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/helpers/projects_helper_util.dart';

import 'projects_helper_util.dart';

class ProjectMessagingRoomHelper {
  static Future<void> createAdvisoryForJoiningMessagingRoom({
    @required BuildContext context,
    @required String requestId,
    @required String projectId,
    @required String timebankId,
    @required UserModel candidateUserModel,
    @required RequestMode requestMode,
  }) {
    _addMemberToAssociatedMessagingRoom(
      candidateUserModel: candidateUserModel,
      projectId: projectId,
      requestId: requestId,
      requestMode: requestMode,
      timebankId: timebankId,
    );

    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Since you are volunteering for this event, you’ve been added to the messaging room. You may leave this room at any time.',
          ),
          actions: [
            FlatButton(
              onPressed: () async {
                Navigator.pop(_);
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> removeMemberFromProjectCommuication({
    @required String projectId,
    @required String timebankId,
    @required UserModel candidateUserModel,
    @required RequestMode requestMode,
  }) async {
    return await _removeMemberFromProjectCommuicationBatch(
      candidateUserModel: candidateUserModel,
      projectId: projectId,
      requestMode: requestMode,
      timebankId: timebankId,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  static WriteBatch _removeMemberFromProjectCommuicationBatch({
    String projectId,
    String timebankId,
    UserModel candidateUserModel,
    RequestMode requestMode,
  }) {
    var batch = DBHelper.batch;

    batch.updateData(DBHelper.projectsRef.document(projectId), {
      DBHelper.ASSOCIATED_MEMBERS + '.' + candidateUserModel.sevaUserID:
          FieldValue.increment(-1)
    });

    batch.updateData(DBHelper.chatsRef.document(projectId + "*" + timebankId), {
      DBHelper.PARTICIPATS: FieldValue.arrayRemove(
        [candidateUserModel.sevaUserID],
      ),
    });

    return batch;
  }

  static Future<void> _justAddMemberToProjectAssiciatedMembers({
    String projectId,
    String newMemberSignup,
  }) async {
    await Firestore.instance
        .collection('projects')
        .document(projectId)
        .updateData({
      DBHelper.ASSOCIATED_MEMBERS: FieldValue.arrayUnion(
        [newMemberSignup],
      )
    });
  }

  static List<String> getAssociatedMembers(
      {Map<String, dynamic> associatedmembers}) {
    List<String> associatedMembersArray = [];

    associatedmembers.forEach((key, value) {
      if (value != null && value > 0) associatedMembersArray.add(key);
    });

    return associatedMembersArray;
  }

  static Future<bool> _addMemberToAssociatedMessagingRoom({
    @required String requestId,
    @required String projectId,
    @required String timebankId,
    @required UserModel candidateUserModel,
    @required RequestMode requestMode,
  }) {
    return _addMemberToAssociatedMessagingRoomBatch(
      associatedMessagingRoomId: projectId + "*" + timebankId,
      candidateUserModel: candidateUserModel,
      projectId: projectId,
      requestId: requestId,
      requestMode: requestMode,
      timebankId: timebankId,
    ).commit().then((value) => true).catchError((onError) {
      return false;
    });
  }

  static Future<bool> createProjectWithMessaging({
    @required ProjectModel projectModel,
    @required UserModel projectCreator,
  }) async {
    return await _createProjectWithMessagingRoomBatch(
      projectCreator: projectCreator,
      projectModel: projectModel,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  static Future<bool> createProjectWithMessagingOneToManyRequest({
    @required ProjectModel projectModel,
    @required UserModel projectCreator,
  }) async {
    return await _createProjectWithMessagingRoomBatchOneToManyRequest(
      projectCreator: projectCreator,
      projectModel: projectModel,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  ///==============================PRIVTAE FUNCTIONS===========================================

  static WriteBatch _createProjectWithMessagingRoomBatch({
    ProjectModel projectModel,
    UserModel projectCreator,
  }) {
    var batch = DBHelper.batch;

    ChatModel chatModel = ChatModel();
    chatModel
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..communityId = projectModel.communityId
      ..groupDetails = MultiUserMessagingModel(
        admins: [projectModel.creatorId],
        imageUrl: projectModel.photoUrl,
        name: projectModel.name,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      )
      ..isTimebankMessage = projectModel.mode == ProjectMode.TIMEBANK_PROJECT
      ..id = projectModel.id + '*' + projectModel.timebankId
      ..lastMessage = DBHelper.NO_MESSAGE
      ..participantInfo = [
        ParticipantInfo(
          id: projectCreator.sevaUserID,
          name: projectCreator.fullname,
          photoUrl: projectCreator.photoURL,
          type: ChatType.TYPE_MULTI_USER_MESSAGING,
        )
      ]
      ..isGroupMessage = true
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..participants = [projectCreator.sevaUserID]
      ..unreadStatus = {
        projectCreator.sevaUserID: 0,
      }
      ..chatContext = ChatContext(
        chatContext: 'Project',
        contextId: projectModel.id,
      );
    projectModel.associatedMessaginfRoomId = chatModel.id;

    batch.setData(
      DBHelper.projectsRef.document(projectModel.id),
      projectModel.toMap(),
    );
    batch.setData(
      DBHelper.chatsRef.document(chatModel.id),
      chatModel.toMap(),
    );

    return batch;
  }

  static Future<String> createMessagingRoomForEvent({
    ProjectModel projectModel,
    UserModel projectCreator,
  }) async {
    ChatModel chatModel = ChatModel();
    chatModel
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..communityId = projectModel.communityId
      ..groupDetails = MultiUserMessagingModel(
        admins: [projectModel.creatorId],
        imageUrl: projectModel.photoUrl,
        name: projectModel.name,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      )
      ..isTimebankMessage = projectModel.mode == ProjectMode.TIMEBANK_PROJECT
      ..id = projectModel.id + '*' + projectModel.timebankId
      ..lastMessage = DBHelper.NO_MESSAGE
      ..participantInfo = [
        ParticipantInfo(
          id: projectCreator.sevaUserID,
          name: projectCreator.fullname,
          photoUrl: projectCreator.photoURL,
          type: ChatType.TYPE_MULTI_USER_MESSAGING,
        )
      ]
      ..isGroupMessage = true
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..participants = [projectCreator.sevaUserID]
      ..unreadStatus = {
        projectCreator.sevaUserID: 0,
      }
      ..chatContext = ChatContext(
        chatContext: 'Project',
        contextId: projectModel.id,
      );

    return await Firestore.instance
        .collection('chatsnew')
        .document(chatModel.id)
        .setData(chatModel.toMap())
        .then((value) => chatModel.id);
  }

  static WriteBatch _createProjectWithMessagingRoomBatchOneToManyRequest({
    @required ProjectModel projectModel,
    @required UserModel projectCreator,
  }) {
    var batch = DBHelper.batch;

    ChatModel chatModel = ChatModel();
    chatModel
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..communityId = projectModel.communityId
      ..interCommunity = projectModel.public
      ..groupDetails = MultiUserMessagingModel(
        admins: [projectModel.creatorId],
        imageUrl: projectModel.photoUrl,
        name: projectModel.name,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      )
      ..isTimebankMessage = projectModel.mode == ProjectMode.TIMEBANK_PROJECT
      ..id = projectModel.id + '*' + projectModel.timebankId
      ..lastMessage = DBHelper.NO_MESSAGE
      ..participantInfo = [
        ParticipantInfo(
          id: projectCreator.sevaUserID,
          name: projectCreator.fullname,
          photoUrl: projectCreator.photoURL,
          type: ChatType.TYPE_MULTI_USER_MESSAGING,
        )
      ]
      ..isGroupMessage = true
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..participants = [projectCreator.sevaUserID]
      ..unreadStatus = {
        projectCreator.sevaUserID: 0,
      }
      ..chatContext = ChatContext(
        chatContext: 'Project',
        contextId: projectModel.id,
      );
    projectModel.associatedMessaginfRoomId = chatModel.id;

    batch.setData(
      DBHelper.projectsRef.document(projectModel.id),
      projectModel.toMap(),
    );
    batch.setData(
      DBHelper.chatsRef.document(chatModel.id),
      chatModel.shareMessage(),
    );

    return batch;
  }

  static WriteBatch _addMemberToAssociatedMessagingRoomBatch({
    String associatedMessagingRoomId,
    String requestId,
    String projectId,
    String timebankId,
    UserModel candidateUserModel,
    RequestMode requestMode,
  }) {
    var batch = DBHelper.batch;

    batch.updateData(DBHelper.projectsRef.document(projectId), {
      DBHelper.ASSOCIATED_MEMBERS + '.' + candidateUserModel.sevaUserID:
          FieldValue.increment(1)
    });

    batch.updateData(DBHelper.chatsRef.document(projectId + "*" + timebankId), {
      DBHelper.PARTICIPATS: FieldValue.arrayUnion(
        [candidateUserModel.sevaUserID],
      ),
      DBHelper.PARTICIPANTS_INFO: FieldValue.arrayUnion([
        ParticipantInfo(
          id: candidateUserModel.sevaUserID,
          name: candidateUserModel.fullname,
          photoUrl: candidateUserModel.photoURL,
          type: ChatType.TYPE_MULTI_USER_MESSAGING,
        ).toMap()
      ])
    });

    return batch;
  }
}
