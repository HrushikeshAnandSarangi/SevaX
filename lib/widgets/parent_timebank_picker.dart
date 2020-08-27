import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/core.dart';

class ParentTimebankPickerWidget extends StatelessWidget {
  final ValueChanged<CommunityModel> onChanged;
  final String selectedTimebank;
  final Color color;

  const ParentTimebankPickerWidget(
      {Key key,
      this.onChanged,
      this.selectedTimebank,
      this.color = Colors.green})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    BuildContext parentContext;
    parentContext = context;
    return RaisedButton(
      textColor: color,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width - 140, 50),
        ),
        child: Text(
          selectedTimebank == '' || selectedTimebank == null
              ? S.of(context).no_timebanks_found
              : selectedTimebank,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      color: Colors.grey[200],
      onPressed: () async {
        FocusScope.of(parentContext).requestFocus(FocusNode());
        _parentSelectionBottomsheet(parentContext, onChanged);
      },
    );
  }
}

void _parentSelectionBottomsheet(BuildContext mcontext, onChanged) {
  showModalBottomSheet(
    context: mcontext,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      var focusNodes = List.generate(1, (_) => FocusNode());
      return Container(
        child: Builder(builder: (context) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0.5,
                automaticallyImplyLeading: true,
                title: Text(
                  S.of(context).select_parent_timebank,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SearchParentTimebanks(
                  keepOnBackPress: false,
                  loggedInUser: SevaCore.of(context).loggedInUser,
                  showBackBtn: false,
                  isFromHome: false,
                  onChanged: onChanged,
                ),
              ));
        }),
      );
    },
  );
}

class SearchParentTimebanks extends StatefulWidget {
  final bool keepOnBackPress;
  final UserModel loggedInUser;
  final bool showBackBtn;
  final bool isFromHome;
  String selectedTimebank;
  final ValueChanged<CommunityModel> onChanged;
  SearchParentTimebanks({
    @required this.keepOnBackPress,
    @required this.loggedInUser,
    @required this.showBackBtn,
    @required this.isFromHome,
    @required this.selectedTimebank,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return SearchParentTimebanksViewState();
  }
}

class SearchParentTimebanksViewState extends State<SearchParentTimebanks> {
  final TextEditingController searchTextController = TextEditingController();
  static String JOIN;
  static String JOINED;
  @override
  void initState() {
    super.initState();
    String _searchText = "";
    final _textUpdates = StreamController<String>();
    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));
    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 500))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        communityBloc.fetchCommunities(s);
        setState(() {
          _searchText = s;
        });
      }
    });
  }

  @override
  void dispose() {
    communityBloc.dispose();
    super.dispose();
  }

  build(context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          S.of(context).find_your_parent_timebank,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: searchTextController,
          decoration: InputDecoration(
              suffixIcon: Offstage(
                offstage: searchTextController.text.length == 0,
                child: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    //searchTextController.clear();
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => searchTextController.clear());
                  },
                ),
              ),
              hasFloatingPlaceholder: false,
              alignLabelWithHint: true,
              isDense: true,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
              filled: true,
              fillColor: Colors.grey[300],
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7)),
              hintText: S.of(context).find_timebank_help_text,
              hintStyle: TextStyle(color: Colors.black45, fontSize: 14)),
        ),
        SizedBox(height: 20),
        Expanded(
          child: buildList(),
        )
      ]),
    );
  }

  Widget buildList() {
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<CommunityModel>>(
        stream: SearchManager.searchCommunity(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data.length != 0) {
                List<CommunityModel> communityList = snapshot.data;
//                print("comm list ${communityList}");
//                communityList
//                    .removeWhere((community) => community.private == true);

                return Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
                    child: ListView.builder(
                        itemCount: communityList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return timeBankWidget(
                              communityModel: communityList[index],
                              context: context,
                              selectedTimebank: this.widget.selectedTimebank);
                        }));
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
                  child: Center(
                    child: Text(S.of(context).no_timebanks_found,
                        style: TextStyle(fontFamily: "Europa", fontSize: 14)),
                  ),
                );
              }
            }
          } else if (snapshot.hasError) {
            return Text(S.of(context).try_later);
          }
          /*else if(snapshot.data==null){
            return Expanded(
              child: Center(
                child: Text('No Timebank found'),
              ),
            );
          }*/
          return Text("");
        });
  }

  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        // style: sectionHeadingStyle,
      ),
    );
  }

  Widget timeBankWidget(
      {CommunityModel communityModel,
      BuildContext context,
      String selectedTimebank}) {
    return ListTile(
      // onTap: goToNext(snapshot.data),
      title: Text(communityModel.name,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
      subtitle: FutureBuilder(
        future: getUserForId(sevaUserId: communityModel.created_by),
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.hasError) {
            return Text(
              S.of(context).timebank,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("...");
          } else if (snapshot.hasData) {
            return Text(
              S.of(context).created_by + ' ' + snapshot.data.fullname,
            );
          } else {
            return Text(
              S.of(context).community,
            );
          }
        },
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        RaisedButton(
          onPressed: communityModel.name != selectedTimebank
              ? () {
                  this.widget.onChanged(communityModel);
                  Navigator.pop(context);
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(communityModel.name == selectedTimebank
                    ? "Current"
                    : S.of(context).choose),
              ),
            ],
          ),
          color: Theme.of(context).accentColor,
          textColor: FlavorConfig.values.buttonTextColor,
          shape: StadiumBorder(),
        )
      ]),
    );
  }
}
