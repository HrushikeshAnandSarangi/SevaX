import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class UserDataBloc extends BlocBase {
  final _user = BehaviorSubject<UserModel>();

  StreamSink<UserModel> get updateUser => _user.sink;

  UserModel get user => _user.value;

  Stream<DocumentSnapshot> getUser(String email) {
    return Firestore.instance.collection("users").document(email).snapshots();
  }

  @override
  void dispose() {
    _user.close();
  }
}
