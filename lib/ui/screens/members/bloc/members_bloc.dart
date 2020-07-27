import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/widgets/APi/user_api.dart';

class MembersBloc extends BlocBase {
  final Map<String, UserModel> _members = {};

  void fetchMembers(String communityId) {
    UserApi.getMembersOfCommunity(communityId).listen((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot document) {
        _members[document.documentID] = UserModel.fromMap(document.data);
      });
    });
  }

  @override
  void dispose() {}
}
