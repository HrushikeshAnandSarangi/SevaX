import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

typedef StringListCallback = void Function(List<String> skills);

class InterestViewNew extends StatefulWidget {
  final UserModel userModel;
  final VoidCallback onSkipped;
  final VoidCallback onBacked;
  final StringListCallback onSelectedInterests;
  final bool automaticallyImplyLeading;
  final bool isFromProfile;

  InterestViewNew(
      {@required this.onSelectedInterests,
      @required this.onSkipped,
      this.onBacked,
      this.userModel,
      this.automaticallyImplyLeading,
      this.isFromProfile});
  @override
  _InterestViewNewState createState() => _InterestViewNewState();
}

class _InterestViewNewState extends State<InterestViewNew> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();

  Map<String, dynamic> interests = {};
  Map<String, dynamic> _selectedInterests = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    print("inside interestsview init state");
    Firestore.instance
        .collection('interests')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        interests[data.documentID] = data['name'];
      });
      widget.userModel.interests.forEach((id) {
        _selectedInterests[id] = interests[id];
      });
      // isDataLoaded = true;

      setState(() {
        isDataLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        leading: widget.automaticallyImplyLeading
            ? null
            : BackButton(
                onPressed: widget.onBacked,
              ),
        title: Text(
          'Interests',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'What are some of your interests and passions that you would be willing to share with your community?',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            TypeAheadField<String>(
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
                List<String> dataCopy = [];
                interests.forEach((k, v) => dataCopy.add(v));
                print(dataCopy);
                dataCopy.retainWhere(
                    (s) => s.toLowerCase().contains(pattern.toLowerCase()));
                return await Future.value(dataCopy);
              },
              itemBuilder: (context, suggestion) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    suggestion,
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
                    'No matching interests found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                _textEditingController.clear();
                if (!_selectedInterests.containsValue(suggestion)) {
                  controller.close();
                  String id = interests.keys
                      .firstWhere((k) => interests[k] == suggestion);
                  _selectedInterests[id] = suggestion;
                  setState(() {});
                }
              },
            ),
            SizedBox(height: 20),
            widget.isFromProfile && !isDataLoaded
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: _selectedInterests.values
                            .toList()
                            .map(
                              (value) => CustomChip(
                                title: value,
                                onDelete: () {
                                  String id = interests.keys
                                      .firstWhere((k) => interests[k] == value);
                                  _selectedInterests.remove(id);
                                  setState(() {});
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
            Spacer(),
            SizedBox(
              width: 134,
              child: RaisedButton(
                onPressed: () {
                  List<String> selectedID = [];
                  _selectedInterests.forEach((id, value) => selectedID.add(id));
                  widget.onSelectedInterests(selectedID);
                },
                child: Text(
                  widget.isFromProfile ? 'Update' : 'Next',
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),
//            widget.userModel.interests == null
//                ? FlatButton(
//                    onPressed: () {
//                      widget.onSkipped();
//                    },
//                    child: Text(
//                      AppConfig.prefs.getBool(AppConfig.skip_interest) == null
//                          ? 'Skip'
//                          : 'Cancel',
//                      style: TextStyle(
//                        color: Theme.of(context).accentColor,
//                      ),
//                    ),
//                  )
//                : Container(),
            FlatButton(
              onPressed: () {
                widget.onSkipped();
              },
              child: Text(
                AppConfig.prefs.getBool(AppConfig.skip_interest) == null
                    ? 'Skip'
                    : 'Cancel',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Padding buildChip(value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
  //     child: Chip(
  //       label: Text(value),
  //       onDeleted: () {
  //         String id = interests.keys.firstWhere((k) => interests[k] == value);
  //         _selectedInterests.remove(id);
  //         setState(() {});
  //       },
  //     ),
  //   );
  // }
}
