import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class MembersBloc extends BlocBase {
  final _members = BehaviorSubject<List<UserModel>>();

  final Map<String, UserModel> _membersMap = {};
  final Map<String, String> _memberEmailIdMapping = {};

  Stream<List<UserModel>> get members => _members.stream;

  void init(String communityId) {
    //Fetch all memebers of the community
    UserRepository.getMembersOfCommunity(communityId).listen((members) {
      members.forEach((member) {
        if (member.sevaUserID != null && member.email != null) {
          _membersMap[member.sevaUserID!] = member;
          _memberEmailIdMapping[member.email!] = member.sevaUserID!;
        }
      });
      _members.add(members);
    }).onError((e) => _members.addError(e));
  }

  /// returns [UserModel] if found and [Null] if user is not found
  UserModel? getMemberFromLocalData({String? userId, String? email}) {
    assert((userId != null || email != null) &&
        !(userId != null && email != null));
    logger.i('userId: $userId, email: $email');
    if (userId != null) {
      if (_isMemberPresentInCache(userId: userId)) {
        return _membersMap[userId];
      }
    } else if (email != null) {
      if (_isMemberPresentInCache(email: email)) {
        return _membersMap[_memberEmailIdMapping[email]];
      }
    }
    logger.e('$userId $email');
    return null;
  }

  Future<UserModel> getUserModel(
      {String? userId, String? email, bool isUserSignedIn = true}) async {
    UserModel? user = getMemberFromLocalData(email: email, userId: userId);
    if (user != null) {
      return Future.value(user);
    } else {
      if (isUserSignedIn) {
        user = userId != null
            ? await UserRepository.fetchUserById(userId)
            : await UserRepository.fetchUserByEmail(email!);
      } else {
        user = userId != null
            ? await Searches.getUserElastic(userId: userId)
            : await Searches.getUserByEmailElastic(userEmail: email!);
      }
      _membersMap[user.sevaUserID!] = user;
      _memberEmailIdMapping[user.email!] = user.sevaUserID!;
      return user;
    }
  }

  //returns List of images for given user ids
  List<String> getUserImagesForUserId(List<String> ids) {
    List<String> images = [];
    ids.forEach((id) {
      images.add(getMemberFromLocalData(userId: id)?.photoURL ?? '');
    });
    return images;
  }

  Future<List<String>> getUserImages(List<String> ids,
      {bool isUserSignedIn = true}) async {
    try {
      List<Future<UserModel>> futures = ids
          .map(
            (id) => id.contains('@')
                ? getUserModel(email: id, isUserSignedIn: isUserSignedIn)
                : getUserModel(userId: id, isUserSignedIn: isUserSignedIn),
          )
          .toList();

      List<UserModel> users = await Future.wait(futures);
      // logger.d("usercount ${users.length}");
      // users.forEach((element) {
      //   // logger.e(element.fullname);
      // });
      return users.map((user) => user.photoURL).whereType<String>().toList();
    } on Exception catch (e) {
      logger.e(e);
      // logger.e("error is -> $e");
      return [];
    }
  }

  Future<void> promoteMember(
      String userId, String communityId, String timebankId) async {
    await UserRepository.promoteOrDemoteUser(
      userId,
      communityId,
      timebankId,
      true,
    );
  }

  Future<void> demoteMember(
      String userId, String communityId, String timebankId) async {
    await UserRepository.promoteOrDemoteUser(
      userId,
      communityId,
      timebankId,
      false,
    );
  }

  Future<void> changeUserCommunity(
      String email, String communityId, String timebankId) async {
    await UserRepository.changeUserCommunity(email, communityId, timebankId);
  }

  @override
  void dispose() {
    _members.close();
  }

  bool _isMemberPresentInCache({String? userId, String? email}) {
    if (userId != null) {
      return _membersMap.containsKey(userId);
    } else if (email != null) {
      return _memberEmailIdMapping.containsKey(email);
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> removeMember(
    String userId,
    String timebankId,
    bool isTimebank,
  ) async {
    return UserRepository.removeMember(
      userId,
      timebankId,
      isTimebank,
    );
  }
}
