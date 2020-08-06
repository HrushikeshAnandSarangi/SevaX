import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

import '../spell_check_manager.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var _debouncer = Debouncer(milliseconds: 500);

  Map<String, dynamic> interests = {};
  Map<String, dynamic> _selectedInterests = {};
  bool isDataLoaded = false;
  bool hasPellError;

  @override
  void initState() {
    print("inside interestsview init state");
    hasPellError = false;
    Firestore.instance
        .collection('interests')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        interests[data.documentID] = data['name'];
      });

      if (widget.userModel.interests != null &&
          widget.userModel.interests.length > 0) {
        widget.userModel.interests.forEach((id) {
          _selectedInterests[id] = interests[id];
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
        leading: widget.automaticallyImplyLeading
            ? null
            : BackButton(
                onPressed: widget.onBacked,
              ),
        title: Text(
          AppLocalizations.of(context).translate('interests', 'title'),
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
              AppLocalizations.of(context).translate('interests', 'title_desc'),
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),

            TypeAheadField<SuggestedItem>(
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              textFieldConfiguration: TextFieldConfiguration(
                style: hasPellError
                    ? TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationStyle: TextDecorationStyle.wavy,
                        decorationThickness: 3,
                      )
                    : TextStyle(),
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate('interests', 'search'),
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
                List<SuggestedItem> dataCopy = [];
                interests.forEach((k, v) => dataCopy.add(SuggestedItem()
                  ..isLocal = true
                  ..suggesttionTitle = v));
                dataCopy.retainWhere((s) => s.suggesttionTitle
                    .toLowerCase()
                    .contains(pattern.toLowerCase()));
                if (pattern.length > 2) {
                  var spellCheckResult =
                      await SpellCheckManager.evaluateSpellingFor(pattern,
                          language: 'en');
                  dataCopy.add(SuggestedItem()
                    ..isLocal = false
                    ..suggesttionTitle = spellCheckResult.hasErros
                        ? pattern
                        : spellCheckResult.correctSpelling);
                }

                return await Future.value(dataCopy);
              },
              itemBuilder: (context, suggestedItem) {
                if (suggestedItem.isLocal)
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      suggestedItem.suggesttionTitle,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                else
                  return getSuggestionLayout(
                    suggestion: suggestedItem.suggesttionTitle,
                  );
              },
              noItemsFoundBuilder: (context) {
                return searchUserDefinedEntity(
                  keyword: _textEditingController.text,
                  language: 'en',
                );
              },
              onSuggestionSelected: (SuggestedItem suggestion) {
                _textEditingController.clear();
                if (!_selectedInterests
                    .containsValue(suggestion.suggesttionTitle)) {
                  controller.close();
                  String id = interests.keys.firstWhere(
                      (k) => interests[k] == suggestion.suggesttionTitle);
                  _selectedInterests[id] = suggestion.suggesttionTitle;
                  setState(() {});
                }
              },
            ),
            SizedBox(height: 20),
            widget.isFromProfile && !isDataLoaded
                ? Center(
                    child: getLinearLoading,
                  )
                : Expanded(
                    child: ListView(
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
                                    String id = interests.keys.firstWhere(
                                        (k) => interests[k] == value);
                                    _selectedInterests.remove(id);
                                    setState(() {});
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
            // Spacer(),
            SizedBox(
              width: 134,
              child: RaisedButton(
                onPressed: () async {
                  var connResult = await Connectivity().checkConnectivity();
                  if (connResult == ConnectivityResult.none) {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)
                            .translate('shared', 'check_internet')),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)
                              .translate('shared', 'dismiss'),
                          onPressed: () =>
                              _scaffoldKey.currentState.hideCurrentSnackBar(),
                        ),
                      ),
                    );
                    return;
                  }
                  List<String> selectedID = [];
                  _selectedInterests.forEach((id, value) => selectedID.add(id));
                  widget.onSelectedInterests(selectedID);
                },
                child: Text(
                  widget.isFromProfile
                      ? AppLocalizations.of(context)
                          .translate('interests', 'update')
                      : AppLocalizations.of(context)
                          .translate('shared', 'next'),
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),

            FlatButton(
              onPressed: () {
                widget.onSkipped();
              },
              child: Text(
                AppConfig.prefs.getBool(AppConfig.skip_interest) == null
                    ? AppLocalizations.of(context).translate('shared', 'skip')
                    : AppLocalizations.of(context)
                        .translate('shared', 'cancel'),
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

        // var beforeStage = hasPellError;

        // print(
        //     "${snapshot.data.hasErros}  ${snapshot.data.errorType} || ${snapshot.data.correctSpelling == null}");
        // if (snapshot.data.hasErros || snapshot.data.correctSpelling == null) {
        //   hasPellError = true;
        //   print("Setting error line");
        // } else {
        //   hasPellError = false;
        //   print("Removing error line");
        // }
        // var afterStage = hasPellError;

        // if (beforeStage != afterStage) {
        //   setState(() {});
        // }
        // print("____________________" + hasPellError.toString());
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
          var interestId = Uuid().generateV4();
          SkillsAndInterestBloc.addInterestToDb(
              interestId: interestId,
              interestLanguage: 'en',
              interestTitle: suggestion);
          interests[interestId] = suggestion;

          if (!_selectedInterests.containsValue(suggestion)) {
            controller.close();
            String id =
                interests.keys.firstWhere((k) => interests[k] == suggestion);
            _selectedInterests[id] = suggestion;
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
                      Text("Add \"${suggestion}\"",
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                      Text(
                        'No data found',
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

class SkillsAndInterestBloc {
  static Future<void> addInterestToDb({
    String interestId,
    String interestTitle,
    String interestLanguage,
  }) async {
    await Firestore.instance
        .collection('interests')
        .document(interestId)
        .setData(
      {'name': interestTitle, 'lang': interestLanguage},
    );
  }

  static Future<void> addSkillToDb({
    String skillId,
    String skillTitle,
    String skillLanguage,
  }) async {
    await Firestore.instance.collection('skills').document(skillId).setData(
      {'name': skillTitle, 'lang': skillLanguage},
    );
  }
}

class SuggestedItem {
  String suggesttionTitle;
  bool isLocal;
}
