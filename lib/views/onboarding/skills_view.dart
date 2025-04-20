import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

import '../spell_check_manager.dart';
import 'interests_view.dart';

typedef StringListCallback = void Function(List<String> skills);
typedef MapListCallback = void Function(
    Map<String, dynamic> _selectedSkillsMap);

class SkillViewNew extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final UserModel? userModel;
  final VoidCallback onSkipped;
  final StringListCallback onSelectedSkills;
  final bool? isFromProfile;
  final String languageCode;
  final bool? isFromRequests;
  final MapListCallback? onSelectedSkillsMap;
  final Map<String, dynamic>? selectedSkills;
  SkillViewNew({
    required this.onSelectedSkills,
    required this.onSkipped,
    this.userModel,
    this.automaticallyImplyLeading = true,
    this.isFromProfile,
    required this.languageCode,
    this.onSelectedSkillsMap,
    this.selectedSkills,
    this.isFromRequests = false,
  });
  @override
  _SkillViewNewState createState() => _SkillViewNewState();
}

class _SkillViewNewState extends State<SkillViewNew> {
  SuggestionsController<SuggestedItem> controller =
      SuggestionsController<SuggestedItem>();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Map<String, dynamic> skills = {};
  Map<String, dynamic> _selectedSkills = {};
  bool isDataLoaded = false;
  bool hasPellError = false;

  @override
  void initState() {
    hasPellError = false;
    CollectionRef.skills
        .orderBy('name')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.id);
        if ((data.data() as Map<String, dynamic>?)
                ?.containsKey(widget.languageCode) ??
            false) {
          skills[data.id] = data[widget.languageCode];
        }

        // ids[data['name']] = data.id;
      });
      if (!widget.isFromRequests!) {
        if (widget.userModel!.skills != null &&
            widget.userModel!.skills!.length > 0) {
          widget.userModel!.skills!.forEach(
            (id) {
              _selectedSkills[id] = skills[id];
            },
          );
        }
      } else {
        _selectedSkills = widget.selectedSkills!;
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
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        title: Text(
          S.of(context).your_skills,
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
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            TypeAheadField<SuggestedItem>(
              suggestionsController: controller,
              decorationBuilder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: child,
                );
              },
              errorBuilder: (context, err) {
                return Text(S.of(context).error_was_thrown);
              },
              debounceDuration: Duration(milliseconds: 600),
              hideOnError: true,
              builder: (context, controller, focusNode) => TextField(
                style: hasPellError
                    ? TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationStyle: TextDecorationStyle.wavy,
                        decorationThickness: 3,
                      )
                    : TextStyle(),
                controller: controller,
                focusNode: focusNode,
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
                    ),
                    onTap: () {
                      _textEditingController.clear();
                      controller.clear();
                    },
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                List<SuggestedItem> dataCopy = [];
                skills.forEach((k, v) => dataCopy.add(SuggestedItem()
                  ..suggestionMode = SuggestionMode.FROM_DB
                  ..suggesttionTitle = v));
                dataCopy.retainWhere(
                  (s) => s.suggesttionTitle.toLowerCase().contains(
                        pattern.toLowerCase(),
                      ),
                );

                if (pattern.length > 2 &&
                    !dataCopy.contains(
                        SuggestedItem()..suggesttionTitle = pattern)) {
                  var spellCheckResult =
                      await SpellCheckManager.evaluateSpellingFor(pattern,
                          language: widget.languageCode);
                  if (spellCheckResult.hasErros!) {
                    dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.USER_DEFINED
                      ..suggesttionTitle = pattern);
                  } else if (spellCheckResult.correctSpelling != pattern) {
                    dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.SUGGESTED
                      ..suggesttionTitle = spellCheckResult.correctSpelling!);

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
                    if (ProfanityDetector()
                        .isProfaneString(suggestedItem.suggesttionTitle)) {
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
                      showLoader: true,
                    );

                  case SuggestionMode.USER_DEFINED:
                    if (ProfanityDetector()
                        .isProfaneString(suggestedItem.suggesttionTitle)) {
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
                    break;

                  default:
                    return Container();
                }
              },
              emptyBuilder: (context) {
                return searchUserDefinedEntity(
                  keyword: _textEditingController.text,
                  language: widget.languageCode,
                  showLoader: false,
                );
              },
              onSelected: (SuggestedItem suggestion) {
                if (ProfanityDetector()
                    .isProfaneString(suggestion.suggesttionTitle)) {
                  return;
                }

                switch (suggestion.suggestionMode) {
                  case SuggestionMode.SUGGESTED:
                    var skillId = Uuid().generateV4();
                    SkillsAndInterestBloc.addSkillToDb(
                        skillId: skillId,
                        skillLanguage: widget.languageCode,
                        skillTitle: suggestion.suggesttionTitle);
                    skills[skillId] = suggestion.suggesttionTitle;
                    break;

                  case SuggestionMode.USER_DEFINED:
                    var skillId = Uuid().generateV4();
                    SkillsAndInterestBloc.addSkillToDb(
                      skillId: skillId,
                      skillLanguage: widget.languageCode,
                      skillTitle: suggestion.suggesttionTitle,
                    );
                    skills[skillId] = suggestion.suggesttionTitle;
                    break;

                  case SuggestionMode.FROM_DB:
                    break;
                }

                _textEditingController.clear();
                if (!_selectedSkills
                    .containsValue(suggestion.suggesttionTitle)) {
                  controller.close();
                  String id = skills.keys.firstWhere(
                      (k) => skills[k] == suggestion.suggesttionTitle);
                  _selectedSkills[id] = suggestion.suggesttionTitle;
                  setState(() {});
                }
              },
            ),
            SizedBox(height: 20),
            widget.isFromProfile! && !isDataLoaded
                ? getLoading
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
              child: CustomElevatedButton(
                color: Theme.of(context).primaryColor,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 2.0,
                textColor: Colors.white,
                onPressed: () async {
                  var connResult = await Connectivity().checkConnectivity();
                  if (connResult == ConnectivityResult.none) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).check_internet),
                        action: SnackBarAction(
                          label: S.of(context).dismiss,
                          onPressed: () => ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar(),
                        ),
                      ),
                    );
                    return;
                  }
                  if (widget.isFromRequests!) {
                    widget.onSelectedSkillsMap!(_selectedSkills);
                  } else {
                    List<String> selectedID = [];
                    _selectedSkills.forEach((id, _) => selectedID.add(id));

                    widget.onSelectedSkills(selectedID);
                  }
                },
                child: Text(
                  widget.isFromRequests!
                      ? S.of(context).done
                      : widget.isFromProfile!
                          ? S.of(context).update
                          : S.of(context).next,
                  style: Theme.of(context).primaryTextTheme.labelLarge,
                ),
              ),
            ),
            CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                widget.onSkipped();
              },
              child: Text(
                widget.isFromRequests!
                    ? S.of(context).cancel
                    : AppConfig.prefs!.getBool(AppConfig.skip_skill) == null
                        ? S.of(context).skip
                        : S.of(context).cancel,
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

//TODO: refactor to one class
  FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
    String? keyword,
    String? language,
    SuggestionMode? suggestionMode,
    bool? showLoader,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword!,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showLoader!
              ? getLoading
              : LinearProgressIndicator(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                );
        }

        return getSuggestionLayout(
            suggestion: keyword,
            suggestionMode: suggestionMode!,
            add: S.of(context).add + ' ',
            context: context);
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
  String? suggestion,
  SuggestionMode? suggestionMode,
  String? add,
  BuildContext? context,
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
                    suggestionMode == SuggestionMode.SUGGESTED
                        ? S.of(context!).suggested
                        : S.of(context!).you_entered,
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
