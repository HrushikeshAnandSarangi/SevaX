import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/model/share_feed_models.dart';

class SearchSegmentBloc {
  List<SearchResultModel> searchResultsFromUserInput = [];
  List<String> selectedMembersForShare = [];

  late List<UserModel> listOfMembersInTimebank;
  var searchResults = BehaviorSubject<List<SearchResultModel>>();
  Stream<List<SearchResultModel>> get searchResultsStream =>
      searchResults.stream;

  void init({required List<UserModel> listOfMembersInTimebank}) {
    this.listOfMembersInTimebank = listOfMembersInTimebank;
    searchResultsFromUserInput = _getAllMembers();
    searchResults.add(searchResultsFromUserInput);
  }

  List<SearchResultModel> _getAllMembers() {
    List<SearchResultModel> locaList = [];
    locaList.clear();

    if (listOfMembersInTimebank == null) listOfMembersInTimebank = [];
    listOfMembersInTimebank.forEach((element) {
      if (element != null)
        locaList.add(SearchResultModel(
          isSelected: selectedMembersForShare.contains(element.sevaUserID),
          userModel: element,
        ));
    });
    return locaList;
  }

  void searchComponent(String searchTerm) {
    searchResultsFromUserInput.clear();

    if (listOfMembersInTimebank == null) listOfMembersInTimebank = [];
    listOfMembersInTimebank.forEach((element) {
      if (element != null &&
          element.fullname?.toLowerCase().contains(searchTerm.toLowerCase()) ==
              true) {
        searchResultsFromUserInput.add(SearchResultModel(
          isSelected: selectedMembersForShare.contains(element.sevaUserID),
          userModel: element,
        ));
      }
    });
    searchResults.add(searchResultsFromUserInput);
  }

  void addMemberToSelectedList(String selectedMemberSevaId) {
    selectedMembersForShare.add(selectedMemberSevaId);
    _updateSelectionPostProcess();
  }

  void removeMemberToSelectedList(String selectedMemberSevaId) {
    selectedMembersForShare.remove(selectedMemberSevaId);
    _updateSelectionPostProcess();
  }

  void _updateSelectionPostProcess() {
    List<SearchResultModel> local = [];
    local.clear();
    if (searchResultsFromUserInput == null) searchResultsFromUserInput = [];
    searchResultsFromUserInput.forEach(
      (element) {
        if (element != null)
          local.add(
            SearchResultModel(
              userModel: element.userModel,
              isSelected: selectedMembersForShare
                  .contains(element.userModel?.sevaUserID),
            ),
          );
      },
    );

    searchResultsFromUserInput.clear();
    searchResultsFromUserInput = local;
    searchResults.add(searchResultsFromUserInput);
  }

  void disposeSelectionsMade() {
    selectedMembersForShare.clear();
    _updateSelectionPostProcess();
  }

  List<UserModel> getSelectedUsersForShare() {
    List<UserModel> selectedUsersLocalList = [];
    if (listOfMembersInTimebank == null) listOfMembersInTimebank = [];
    listOfMembersInTimebank.forEach((element) {
      if (element != null &&
          selectedMembersForShare.contains(element.sevaUserID)) {
        selectedUsersLocalList.add(element);
      }
    });
    return selectedUsersLocalList;
  }
}
