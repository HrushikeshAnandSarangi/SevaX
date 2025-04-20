import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class SearchBloc extends BlocBase {
  final TimebankModel? timebank;
  final CommunityModel? community;
  final UserModel? user;
  SearchBloc({this.community, this.timebank, this.user})
      : assert(timebank != null),
        assert(user != null);

  final _searchText = BehaviorSubject<String>();
  final _debouncer = Debouncer(milliseconds: 800);

  void onSearchChange(String value) {
    if (value != null || value != "") {
      _debouncer.run(() {
        _searchText.sink.add(value);
      });
    }
  }

  Stream<String> get searchText => _searchText.stream;

  @override
  void dispose() {
    _searchText.close();
  }
}
