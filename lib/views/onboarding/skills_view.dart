import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

import '../spell_check_manager.dart';
import 'interests_view.dart';

typedef StringListCallback = void Function(List<String> skills);

class SkillViewNew extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final UserModel userModel;
  final VoidCallback onSkipped;
  final StringListCallback onSelectedSkills;
  final bool isFromProfile;

  SkillViewNew({
    @required this.onSelectedSkills,
    @required this.onSkipped,
    this.userModel,
    this.automaticallyImplyLeading = true,
    this.isFromProfile,
  });
  @override
  _SkillViewNewState createState() => _SkillViewNewState();
}

class _SkillViewNewState extends State<SkillViewNew> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool autovalidate = false;
  Map<String, dynamic> skills = {};
  Map<String, dynamic> _selectedSkills = {};
  bool isDataLoaded = false;
  @override
  void initState() {
    print(widget.userModel.skills);
    Firestore.instance
        .collection('skills')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.documentID);
        skills[data.documentID] = data['name'];

        // ids[data['name']] = data.documentID;
      });
      if (widget.userModel.skills != null &&
          widget.userModel.skills.length > 0) {
        widget.userModel.skills.forEach((id) {
          _selectedSkills[id] = skills[id];
          // selectedChips.add(buildChip(id: id, value: skills[id]));
        });
      }
      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        title: Text(
          S.of(context).skills.firstWordUpperCase(),
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
              S.of(context).skills_description,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            TypeAheadField<String>(
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                // color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                // shape: RoundedRectangleBorder(),
              ),
              hideOnError: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: S.of(context).search,
                  filled: true,
                  fillColor: Colors.grey[300],
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7)),
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
                skills.forEach((id, skill) => dataCopy.add(skill));
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
                return searchUserDefinedEntity(
                  keyword: _textEditingController.text,
                  language: 'en',
                );
              },
              onSuggestionSelected: (suggestion) {
                _textEditingController.clear();
                if (!_selectedSkills.containsValue(suggestion)) {
                  controller.close();
                  String id =
                      skills.keys.firstWhere((k) => skills[k] == suggestion);
                  _selectedSkills[id] = suggestion;
                  setState(() {});
                }
              },
            ),
            SizedBox(height: 20),
            widget.isFromProfile && !isDataLoaded
                ? LoadingIndicator()
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Wrap(
                          runSpacing: 5.0,
                          spacing: 5.0,
                          children: _selectedSkills.values
                              .toList()
                              .map(
                                (value) => value == null
                                    ? Container()
                                    : CustomChip(
                                        title: value,
                                        onDelete: () {
                                          String id = skills.keys.firstWhere(
                                              (k) => skills[k] == value);
                                          _selectedSkills.remove(id);
                                          setState(() {});
                                        },
                                      ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
            //   Spacer(),

            SizedBox(
              width: 134,
              child: RaisedButton(
                onPressed: () async {
                  var connResult = await Connectivity().checkConnectivity();
                  if (connResult == ConnectivityResult.none) {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).check_internet),
                        action: SnackBarAction(
                          label: S.of(context).dismiss,
                          onPressed: () =>
                              _scaffoldKey.currentState.hideCurrentSnackBar(),
                        ),
                      ),
                    );
                    return;
                  }
                  List<String> selectedID = [];
                  _selectedSkills.forEach((id, _) => selectedID.add(id));
                  print(selectedID);
                  widget.onSelectedSkills(selectedID);
                },
                child: Text(
                  widget.isFromProfile
                      ? S.of(context).update
                      : S.of(context).next,
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                widget.onSkipped();
              },
              child: Text(
                AppConfig.prefs.getBool(AppConfig.skip_skill) == null
                    ? S.of(context).skip
                    : S.of(context).cancel,
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

  FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
    String keyword,
    String language,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return getLinearLoading;
        }

        return getSuggestionLayout(
          suggestion:
              !snapshot.data.hasErros ? snapshot.data.correctSpelling : keyword,
        );
      },
    );
  }

  Widget get getLinearLoading {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Padding getSuggestionLayout({
    String suggestion,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: GestureDetector(
        onTap: () {
          _textEditingController.clear();
          controller.close();
          var skillId = Uuid().generateV4();
          SkillsAndInterestBloc.addSkillToDb(
            skillId: skillId,
            skillLanguage: 'en',
            skillTitle: suggestion,
          );
          skills[skillId] = suggestion;

          if (!_selectedSkills.containsValue(suggestion)) {
            controller.close();
            String id = skills.keys.firstWhere((k) => skills[k] == suggestion);
            _selectedSkills[id] = suggestion;
            setState(() {});
          }
        },
        child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${S.of(context).add.toUpperCase()} \"${suggestion}\"",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                      Text(
                        S.of(context).no_data,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ],
            )),
      ),
    );
  }
}
