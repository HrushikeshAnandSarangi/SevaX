import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/widgets/APi/user_api.dart';

class BlockedMembersBloc {
  final _blockedMembers = BehaviorSubject<List<UserModel>>();

  Stream<List<UserModel>> get blockedMembers => _blockedMembers.stream;

  void init(String userId) {
    UserApi.getBlockedMembers(userId).listen((QuerySnapshot event) {
      List<UserModel> blockedMembers = [];
      event.documents.forEach((DocumentSnapshot element) {
        blockedMembers
            .add(UserModel.fromMap(element.data, 'blocked_members_bloc'));
      });
      _blockedMembers.add(blockedMembers);
    });
  }

  Future<void> unblockMember({
    String loggedInUserEmail,
    String userId,
    String unblockedUserId,
    String unblockedUserEmail,
  }) async {
    return UserApi.unblockUser(
      loggedInUserEmail: loggedInUserEmail,
      userId: userId,
      unblockedUserId: unblockedUserId,
      unblockedUserEmail: unblockedUserEmail,
    );
  }

  void dispose() {
    _blockedMembers.close();
  }
}
