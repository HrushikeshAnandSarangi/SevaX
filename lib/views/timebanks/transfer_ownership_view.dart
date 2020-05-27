import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';

class TransferOwnerShipView extends StatefulWidget {
  final TimebankModel timebankModel;

  TransferOwnerShipView({this.timebankModel});

  @override
  _TransferOwnerShipViewState createState() => _TransferOwnerShipViewState();
}

class _TransferOwnerShipViewState extends State<TransferOwnerShipView> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var groupMembersList = List<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersList();
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankModel.id,
    ).then((onValue) {
      setState(() {
        groupMembersList = onValue;
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
                'User Name',
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
              getDataList(),
              SizedBox(
                height: 15,
              ),
              getInfoWidget(),
              SizedBox(
                height: 15,
              ),
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
          onPressed: () {},
          child: Text("DELETE",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme.primaryColor,
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

  Widget getDataList() {
    //Stream builder should get implement to show groups or timebanks
//    return StreamBuilder(
//      stream: ,
//      builder: ,
//    );

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 3,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return timeBankOrGroupCard();
        });
  }
}

Widget timeBankOrGroupCard() {
  return Card(
    elevation: 1,
    child: ListTile(
      title: Text("Group or Timebank Name"),
    ),
  );
}
