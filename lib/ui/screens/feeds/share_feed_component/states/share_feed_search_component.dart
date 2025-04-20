import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/bloc/share_feed_bloc_component.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/model/share_feed_models.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../../../../flavor_config.dart';

///Search component in share feeds
class SearchComponent extends StatelessWidget {
  final PageController? pageController;
  // final TimebankModel timebankModel;
  final List<UserModel>? membersInTimebank;
  final SearchSegmentBloc? searchSegmentBloc;
  final UserModel? loggedInUser;

  List<UserModel> selectedMembersToShareWith = [];
  TextEditingController searchController = TextEditingController();
  SearchComponent({
    this.pageController,
    // this.timebankModel,
    this.membersInTimebank,
    this.searchSegmentBloc,
    this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    final _membersBloc = Provider.of<MembersBloc>(context, listen: false);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 26,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          S.of(context).select_volunteer,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomCloseButton(
                  onCleared: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            height: 1,
            color: HexColor('#ECEDF1'),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 17,
            ),
            child: Text(
              'Whom do you want to share this Post?',
              style: TextStyle(
                fontSize: 18,
                color: HexColor('#636972'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            decoration: new BoxDecoration(
              color: HexColor('#ECEDF1'),
              borderRadius: new BorderRadius.all(
                const Radius.circular(20.0),
              ),
            ),
            height: 45,
            child: Container(
              width: double.infinity,
              child: TextFormField(
                controller: searchController,
                style: TextStyle(
                  color: Colors.black87,
                ),
                validator: (value) {
                  return null;
                },
                onChanged: (text) {
                  searchSegmentBloc?.searchComponent(text);
                },
                decoration: InputDecoration(
                  errorMaxLines: 2,
                  suffixIcon: CustomCloseButton(
                    onCleared: () {
                      searchController.clear();
                      searchSegmentBloc?.searchComponent('');
                    },
                  ),
                  alignLabelWithHint: true,
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                  filled: true,
                  fillColor: HexColor('#ECEDF1'),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white),
                    borderRadius: new BorderRadius.circular(25.7),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7)),
                  hintText: S.of(context).search,
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                ),
              ),
            ),
          ),
          StreamBuilder<List<SearchResultModel>>(
            stream: searchSegmentBloc!.searchResultsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingIndicator();
              } else
                return Expanded(
                  child: snapshot.data!.isEmpty
                      ? Center(
                          child: Text(S.of(context).no_volunteers_available))
                      : ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return snapshot
                                        .data![index].userModel?.sevaUserID !=
                                    loggedInUser?.sevaUserID
                                ? InkWell(
                                    onTap: () {
                                      handleSelection(
                                        associatedSevaUserId: snapshot
                                                .data?[index]
                                                .userModel
                                                ?.sevaUserID ??
                                            '',
                                        isSelected:
                                            snapshot.data?[index].isSelected ??
                                                false,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value:
                                              snapshot.data![index].isSelected,
                                          onChanged: (selectedItem) {
                                            handleSelection(
                                              associatedSevaUserId: snapshot
                                                      .data![index]
                                                      .userModel!
                                                      .sevaUserID ??
                                                  '',
                                              isSelected: snapshot.data![index]
                                                      .isSelected ??
                                                  false,
                                            );
                                          },
                                        ),
                                        Text(
                                          "${_membersBloc.getMemberFromLocalData(
                                                userId: snapshot
                                                        .data![index]
                                                        .userModel
                                                        ?.sevaUserID ??
                                                    '',
                                              )?.fullname ?? ''}",
                                          style: TextStyle(
                                            color: HexColor('#4A4A4A'),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container();
                          },
                        ),
                );
            },
          ),
          Center(
            child: CustomElevatedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  var listOfSelectedMembers =
                      searchSegmentBloc?.getSelectedUsersForShare();
                  if ((listOfSelectedMembers?.length ?? 0) > 0) {
                    pageController?.animateToPage(
                      2,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  } else {
                    showSelectMembersAlert(
                        context: context, message: S.of(context).select_user);
                  }
                },
                child: Text(S.of(context).next)),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  void showSelectMembersAlert(
      {required BuildContext context, required String message}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(message),
          actions: [
            CustomTextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                S.of(context).ok,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void handleSelection({
    required bool isSelected,
    required String associatedSevaUserId,
  }) {
    if (isSelected)
      searchSegmentBloc?.removeMemberToSelectedList(associatedSevaUserId);
    else
      searchSegmentBloc?.addMemberToSelectedList(associatedSevaUserId);
  }
}

class CustomCloseButton extends StatelessWidget {
  final VoidCallback onCleared;

  const CustomCloseButton({Key? key, required this.onCleared})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: IconButton(
            icon: Icon(Icons.circle),
            color: HexColor('#979797'),
            onPressed: () {},
          ),
        ),
        Container(
          child: IconButton(
            splashColor: Colors.transparent,
            icon: Icon(Icons.clear, color: Colors.white, size: 12),
            onPressed: onCleared,
          ),
        ),
      ],
    );
  }
}
