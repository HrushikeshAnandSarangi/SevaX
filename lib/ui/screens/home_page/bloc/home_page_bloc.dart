// import 'package:rxdart/subjects.dart';
// import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// import 'package:sevaexchange/utils/log_printer/log_printer.dart';
// import 'package:sevaexchange/utils/utils.dart';

// class HomePageBloc {
//   final _currentTimebank = BehaviorSubject<TimebankModel>();
//   final _isAdmin = BehaviorSubject<bool>();

//   Function(TimebankModel) get changeTimebank => _currentTimebank.sink.add;

//   Stream<TimebankModel> get currentTimebank => _currentTimebank.stream;

//   bool isAdmin(String userId) {
//     try {
//       return isMemberAnAdmin(_currentTimebank.value, userId);
//     } catch (e) {
//       logger.e(e);
//       return false;
//     }
//   }

//   void dispose() {
//     _isAdmin.close();
//     _currentTimebank.close();
//   }
// }
