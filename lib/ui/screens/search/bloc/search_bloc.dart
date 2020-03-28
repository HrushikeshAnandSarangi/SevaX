import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class SearchBloc extends BlocBase {
  final _searchText = BehaviorSubject<String>();
  final _debouncer = Debouncer(milliseconds: 500);

  void onSearchChange(String value) {
    if (value != null || value != "") {
      _debouncer.run(() {
        _searchText.sink.add(value);
      });
    }
  }

  Stream<String> get searchText => _searchText.stream;

  void searchAfterDelay() {
    _searchText.onAdd(_debouncer.run(() => print("hello")));
  }

  @override
  void dispose() {
    _searchText.close();
  }
}
