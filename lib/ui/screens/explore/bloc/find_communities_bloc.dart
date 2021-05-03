import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';

// enum CompareUserStatus { JOINED, REQUESTED, REJECTED, JOIN }

class FindCommunitiesBloc {
  final _searchText = BehaviorSubject<String>();
  final _nearyByCommunities = BehaviorSubject<List<CommunityModel>>();
  final seeAll = BehaviorSubject<bool>();

  Stream<String> get searchKey => _searchText.stream;
  Stream<List<CommunityModel>> get nearyByCommunities =>
      _nearyByCommunities.stream;
  Stream<bool> get seeAllBool => seeAll.stream;

  final _debouncer = Debouncer(milliseconds: 800);
  final _debouncer2 = Debouncer(milliseconds: 200);

  void onSearchChange(String value) {
    if (value != null || value != "") {
      _debouncer.run(() {
        _searchText.sink.add(value);
      });
    }
  }

  void onSeeAllButtonPress(bool val) {
    _debouncer2.run(() {
      seeAll.sink.add(val);
    });
  }

  void init(NearBySettings nearbySettings) {
    seeAll.sink.add(false);
    _searchText.sink.add('');
    getNearCommunitiesListStream(nearbySettings: nearbySettings)
        .listen((event) {
      _nearyByCommunities.add(event);
    }).onError(
      (e) => _nearyByCommunities.addError('GPS_ERROR'),
    );
  }

  CompareUserStatus compareUserStatus(
    CommunityModel communityModel,
    String seveaUserId,
  ) {
    if (communityModel.members.contains(seveaUserId) ||
        communityModel.admins.contains(seveaUserId)) {
      return CompareUserStatus.JOINED;
    } else {
      return CompareUserStatus.JOIN;
    }
  }

  void dispose() {
    _nearyByCommunities.close();
    _searchText.close();
    seeAll.close();
  }
}
