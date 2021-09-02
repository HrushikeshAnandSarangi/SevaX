import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class UserBloc {
  final _user = BehaviorSubject<UserModel>();

  Stream<UserModel> get user => _user.stream;

  UserModel get loggedInUser => _user.value;

  void loadUser(String userEmail) {
    logger.i("loading user ");
    UserRepository.getUserStream(userEmail).listen(
      (event) {
        _user.add(event);
      },
    ).onError(
      (error) {
        logger.e(error);
        _user.addError(error);
      },
    );
  }

  void get clearUserData => _user.add(null);

  void dispose() {
    _user.add(null);
    _user.close();
  }
}
