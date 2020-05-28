import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransferOwnerShipView extends StatefulWidget {
  final String timebankId;
  final Map<String, dynamic> responseData;
  final ReportedMembersModel reportedMemberModel;

  TransferOwnerShipView({this.timebankId, this.responseData, this.reportedMemberModel});

  @override
  _TransferOwnerShipViewState createState() => _TransferOwnerShipViewState();
}

class _TransferOwnerShipViewState extends State<TransferOwnerShipView> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var groupMembersList = List<String>();
  List<Map<String, dynamic>> ownerGroupsArr;
  UserModel selectedNewOwner = null;
  var allItems = List<String>();
  var admins, coordinators, members;
  TimebankModel tbmodel;
  var futures = <Future>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersList();
    ownerGroupsArr = widget.responseData['ownerGroupsArr'];
  }

  void getMembersList() {
    FirestoreManager.getTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        tbmodel = onValue;
        admins = onValue.admins;
        coordinators = onValue.coordinators;
        members = onValue.members;
        allItems.addAll(admins);
        allItems.addAll(coordinators);
        allItems.addAll(members);
        groupMembersList = allItems;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Delete User',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Europa'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.reportedMemberModel.reportedUserName,
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                    color: FlavorConfig.values.theme.primaryColor),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Transfer ownership of this user's data to another user, like manager.",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Europa',
                ),
              ),
              searchUser(),
              SizedBox(
                height: 15,
              ),
              getDataList(ownerGroupsArr),
              SizedBox(
                height: 15,
              ),
//              getInfoWidget(),
//              SizedBox(
//                height: 15,
//              ),
              Text(
                'Transfer to',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Europa',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Search a user',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Europa',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 15,
              ),
              optionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget optionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "CANCEL",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa'),
          ),
          textColor: Colors.grey,
        ),
        FlatButton(
          child: Text("DELETE",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme.primaryColor,
          onPressed: () async {
            if(selectedNewOwner==null){
              print("reporter timebank creator id is ${tbmodel.creatorId}");
              ownerGroupsArr.forEach((group)=>
                  futures.add(Firestore.instance
                      .collection('users')
                      .document(group['id'])
                      .updateData({"creator_id":tbmodel.creatorId}))
              );
              await Future.wait(futures);
              Map<String, dynamic> responseObj = await removeMemberFromTimebank(sevauserid: widget.reportedMemberModel.reportedId, timebankId: tbmodel.id);
              if(responseObj['deletable']==true){
                getSuccessDialog(context);
              }else{
                getErrorDialog(context);
              }

            }else{
              print("new owner creator id is ${selectedNewOwner.sevaUserID}");
              ownerGroupsArr.forEach((group)=>
                  futures.add(Firestore.instance
                      .collection('users')
                      .document(group['id'])
                      .updateData({"creator_id":selectedNewOwner.sevaUserID}))
              );
              await Future.wait(futures);
              Map<String, dynamic> responseObj = await removeMemberFromTimebank(sevauserid: widget.reportedMemberModel.reportedId, timebankId: tbmodel.id);
              if(responseObj['deletable']==true){
                getSuccessDialog(context);
              }else{
                getErrorDialog(context);
              }
            }
          },
        )
      ],
    );
  }

  Widget searchUser() {
    return TypeAheadField<UserModel>(
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      textFieldConfiguration: TextFieldConfiguration(
        controller: _textEditingController,
        decoration: InputDecoration(
          hintText: 'Search',
          filled: true,
          fillColor: Colors.grey[300],
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white),
            borderRadius: new BorderRadius.circular(25.7),
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: new BorderRadius.circular(25.7)),
          contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
          suffixIcon: InkWell(
            splashColor: Colors.transparent,
            child: Icon(
              Icons.clear,
              color: Colors.grey,
              // color: _textEditingController.text.length > 1
              //     ? Colors.black
              //     : Colors.grey,
            ),
            onTap: () {
              _textEditingController.clear();
              controller.close();
            },
          ),
        ),
      ),
      suggestionsBoxController: controller,
      suggestionsCallback: (pattern) async {
//        List<String> dataCopy = [];
//        // interests.forEach((k, v) => dataCopy.add(v));
//        print(dataCopy);
//        dataCopy.retainWhere(
//            (s) => s.toLowerCase().contains(pattern.toLowerCase()));
//        //  return await Future.value(dataCopy);

        return await SearchManager.searchForUserWithTimebankIdFuture(
            queryString: pattern, validItems: groupMembersList);
      },
      itemBuilder: (context, suggestion) {
        print("suggest ${suggestion}");
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            suggestion.fullname,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        );
      },
      noItemsFoundBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No users found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      },
      onSuggestionSelected: (suggestion) {
        selectedNewOwner = suggestion;
        _textEditingController.clear();
//        if (!_selectedInterests.containsValue(suggestion)) {
//          controller.close();
//          String id = interests.keys
//              .firstWhere((k) => interests[k] == suggestion);
//          _selectedInterests[id] = suggestion;
//          setState(() {});
//        }
      },
    );
  }

  Widget getInfoWidget() {
    return Container(
      color: Colors.grey[100],
      child: ListTile(
        leading: Image.asset(
          'lib/assets/images/info.png',
          color: FlavorConfig.values.theme.primaryColor,
          height: 30,
          width: 30,
        ),
        title: Text('All data not transferred will be deleted.'),
      ),
    );
  }

  Widget getDataList(ownerGroupsArr) {

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: ownerGroupsArr.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return timeBankOrGroupCard(ownerGroupsArr[index]);
        });
  }

    getSuccessDialog(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("User is successfully removed from the timebank"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("Error occured! Please come back later and try again. "),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Widget timeBankOrGroupCard(ownerGroupData) {
  return Card(
    elevation: 1,
    child: ListTile(
      title: Text(ownerGroupData[' name ']),
    ),
  );
}
