import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/user_repository.dart';

class BlockedMembersBloc {
  final _blockedMembers = BehaviorSubject<List<UserModel>>();

  Stream<List<UserModel>> get blockedMembers => _blockedMembers.stream;

  void init(String userId) {
    UserRepository.getBlockedMembers(userId).listen((QuerySnapshot event) {
      List<UserModel> blockedMembers = [];
      event.docs.forEach((DocumentSnapshot element) {
        blockedMembers.add(UserModel.fromMap(
            (element.data() ?? {}) as Map<String, dynamic>,
            'blocked_members_bloc'));
      });
      _blockedMembers.add(blockedMembers);
    });
  }

  Future<void> unblockMember({
    required String loggedInUserEmail,
    required String userId,
    required String unblockedUserId,
    required String unblockedUserEmail,
  }) async {
    return UserRepository.unblockUser(
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
