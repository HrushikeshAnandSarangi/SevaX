import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

import '../spell_check_manager.dart';

typedef StringListCallback = void Function(List<String> skills);

class InterestViewNew extends StatefulWidget {
  final UserModel userModel;
  final VoidCallback onSkipped;
  final VoidCallback onBacked;
  final VoidCallback onPrevious;

  final StringListCallback onSelectedInterests;
  final bool automaticallyImplyLeading;
  final bool isFromProfile;
  final String languageCode;

  InterestViewNew(
      {@required this.onSelectedInterests,
      @required this.onSkipped,
      this.onBacked,
      this.userModel,
      this.automaticallyImplyLeading,
      this.isFromProfile,
      this.onPrevious,
      @required this.languageCode});
  @override
  _InterestViewNewState createState() => _InterestViewNewState();
}

class _InterestViewNewState extends State<InterestViewNew> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Map<String, dynamic> interests = {};
  Map<String, dynamic> _selectedInterests = {};
  bool isDataLoaded = false;
  bool hasPellError;

  @override
  void initState() {
    hasPellError = false;
    CollectionRef.interests.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot data) {
        if (data.data().containsKey(widget.languageCode)) {
          interests[data.id] = data[widget.languageCode];
        }
      });

      if (widget.userModel.interests != null && widget.userModel.interests.length > 0) {
        widget.userModel.interests.forEach((id) {
          _selectedInterests[id] = interests[id];
        });
      }

      if (mounted)
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
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        leading: widget.automaticallyImplyLeading
            ? null
            : BackButton(
                onPressed: widget.onBacked,
              ),
        title: Text(
          S.of(context).your_interests,
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
              S.of(context).interests_description,
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
              errorBuilder: (context, err) {
                return Text(S.of(context).error_occured);
              },
              debounceDuration: Duration(milliseconds: 300),
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
                  hintText: S.of(context).search,
                  filled: true,
                  fillColor: Colors.grey[300],
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
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
                interests.forEach(
                  (k, v) => dataCopy.add(SuggestedItem()
                    ..suggestionMode = SuggestionMode.FROM_DB
                    ..suggesttionTitle = v),
                );
                dataCopy.retainWhere((s) => s.suggesttionTitle.toLowerCase().contains(pattern.toLowerCase()));

                if (pattern.length > 2 && !dataCopy.contains(SuggestedItem()..suggesttionTitle = pattern)) {
                  var spellCheckResult =
                      await SpellCheckManager.evaluateSpellingFor(pattern, language: widget.languageCode);
                  if (spellCheckResult.hasErros) {
                    dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.USER_DEFINED
                      ..suggesttionTitle = pattern);
                  } else if (spellCheckResult.correctSpelling != pattern) {
                    dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.SUGGESTED
                      ..suggesttionTitle = spellCheckResult.correctSpelling);

                    dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.USER_DEFINED
                      ..suggesttionTitle = pattern);
                  } else {
                    dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.USER_DEFINED
                      ..suggesttionTitle = pattern);
                  }
                }

                return await Future.value(dataCopy);
              },
              itemBuilder: (context, suggestedItem) {
                switch (suggestedItem.suggestionMode) {
                  case SuggestionMode.FROM_DB:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        suggestedItem.suggesttionTitle,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    );

                  case SuggestionMode.SUGGESTED:
                    if (ProfanityDetector().isProfaneString(suggestedItem.suggesttionTitle)) {
                      return ProfanityDetector.getProanityAdvisory(
                        suggestion: suggestedItem.suggesttionTitle,
                        suggestionMode: SuggestionMode.SUGGESTED,
                        context: context,
                      );
                    }
                    return searchUserDefinedEntity(
                      keyword: suggestedItem.suggesttionTitle,
                      language: widget.languageCode,
                      suggestionMode: suggestedItem.suggestionMode,
                      showLoader: true,
                    );

                  case SuggestionMode.USER_DEFINED:
                    if (ProfanityDetector().isProfaneString(suggestedItem.suggesttionTitle)) {
                      return ProfanityDetector.getProanityAdvisory(
                        suggestion: suggestedItem.suggesttionTitle,
                        suggestionMode: SuggestionMode.USER_DEFINED,
                        context: context,
                      );
                    }

                    return searchUserDefinedEntity(
                      keyword: suggestedItem.suggesttionTitle,
                      language: widget.languageCode,
                      suggestionMode: suggestedItem.suggestionMode,
                      showLoader: false,
                    );

                  default:
                    return Container();
                }
              },
              noItemsFoundBuilder: (context) {
                return searchUserDefinedEntity(
                  keyword: _textEditingController.text,
                  language: widget.languageCode,
                  showLoader: false,
                );
              },
              onSuggestionSelected: (SuggestedItem suggestion) {
                if (ProfanityDetector().isProfaneString(suggestion.suggesttionTitle)) {
                  return;
                }

                switch (suggestion.suggestionMode) {
                  case SuggestionMode.SUGGESTED:
                    var interestId = Uuid().generateV4();
                    SkillsAndInterestBloc.addInterestToDb(
                      interestId: interestId,
                      interestLanguage: widget.languageCode,
                      interestTitle: suggestion.suggesttionTitle,
                    );
                    interests[interestId] = suggestion.suggesttionTitle;
                    break;

                  case SuggestionMode.USER_DEFINED:
                    var interestId = Uuid().generateV4();
                    SkillsAndInterestBloc.addInterestToDb(
                        interestId: interestId,
                        interestLanguage: widget.languageCode,
                        interestTitle: suggestion.suggesttionTitle);
                    interests[interestId] = suggestion.suggesttionTitle;
                    break;

                  case SuggestionMode.FROM_DB:
                    break;
                }
                _textEditingController.clear();
                // controller.close();

                if (!_selectedInterests.containsValue(suggestion.suggesttionTitle)) {
                  controller.close();
                  String id = interests.keys.firstWhere((k) => interests[k] == suggestion.suggesttionTitle);
                  _selectedInterests[id] = suggestion.suggesttionTitle;
                  setState(() {});
                }
              },
            ),
            SizedBox(height: 20),
            widget.isFromProfile && !isDataLoaded
                ? getLoading
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
                                (value) => value != null && value != ''
                                    ? CustomChip(
                                        title: value,
                                        onDelete: () {
                                          String id = interests.keys.firstWhere((k) => interests[k] == value);
                                          _selectedInterests.remove(id);
                                          setState(() {});
                                        },
                                      )
                                    : Container(),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
            // Spacer(),
            SizedBox(
              width: 134,
              child: CustomElevatedButton(
                onPressed: () async {
                  var connResult = await Connectivity().checkConnectivity();
                  if (connResult == ConnectivityResult.none) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).check_internet),
                        action: SnackBarAction(
                          label: S.of(context).dismiss,
                          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                  widget.isFromProfile ? S.of(context).update : S.of(context).next,
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),
            CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              onPressed: () {
                widget.onSkipped();
              },
              child: Text(
                AppConfig.prefs.getBool(AppConfig.skip_interest) == null ? S.of(context).skip : S.of(context).cancel,
                style: TextStyle(
                  color: Colors.white,
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
    SuggestionMode suggestionMode,
    bool showLoader,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showLoader
              ? getLoading
              : LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                );
        }

        return getSuggestionLayout(
            suggestion: keyword, suggestionMode: suggestionMode, add: S.of(context).add + ' ', context: context);
      },
    );
  }

  Widget get getLoading {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LoadingIndicator(),
    );
  }
}

Padding getSuggestionLayout({
  String suggestion,
  String add,
  SuggestionMode suggestionMode,
  BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
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
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: add,
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        TextSpan(
                          text: "\"${suggestion}\"",
                          style: suggestionMode == SuggestionMode.SUGGESTED
                              ? TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                )
                              : TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red,
                                  decorationStyle: TextDecorationStyle.wavy,
                                  decorationThickness: 1.5,
                                ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    suggestionMode == SuggestionMode.SUGGESTED ? S.of(context).suggested : S.of(context).you_entered,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
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
  );
}

class SkillsAndInterestBloc {
  static Future<void> addInterestToDb({
    String interestId,
    String interestTitle,
    String interestLanguage,
  }) async {
    await CollectionRef.interests.doc(interestId).set(
      {
        'name': interestTitle?.firstWordUpperCase(),
        'lang': interestLanguage,
        interestLanguage: interestTitle?.firstWordUpperCase(),
        'id': interestId
      },
    );
  }

  static Future<void> addSkillToDb({
    String skillId,
    String skillTitle,
    String skillLanguage,
  }) async {
    await CollectionRef.skills.doc(skillId).set(
      {
        'name': skillTitle?.firstWordUpperCase(),
        'lang': skillLanguage,
        skillLanguage: skillTitle?.firstWordUpperCase(),
        'id': skillId
      },
    );
  }
}

class SuggestedItem {
  String suggesttionTitle;
  SuggestionMode suggestionMode;

  @override
  bool operator ==(Object other) => other is SuggestedItem && other.suggesttionTitle == this.suggesttionTitle;
}

enum SuggestionMode {
  FROM_DB,
  USER_DEFINED,
  SUGGESTED,
}
