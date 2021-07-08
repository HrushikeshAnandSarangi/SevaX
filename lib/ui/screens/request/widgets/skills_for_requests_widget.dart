import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

typedef MapListCallback = void Function(
    Map<String, dynamic> _selectedSkillsMap);

class SkillsForRequests extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> selectedSkills;
  final MapListCallback onSelectedSkillsMap;

  SkillsForRequests(
      {this.languageCode, this.selectedSkills, this.onSelectedSkillsMap});

  @override
  _SkillsForRequestsState createState() => _SkillsForRequestsState();
}

class _SkillsForRequestsState extends State<SkillsForRequests> {
  Map<String, dynamic> skills = {};
  Map<String, dynamic> _selectedSkills = {};
  bool isDataLoaded = false;
  bool hasPellError = false;
  TextEditingController _textEditingController = TextEditingController();
  SuggestionsBoxController controller = SuggestionsBoxController();

  @override
  void initState() {
    CollectionRef.skills
        .orderBy('name')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.id);
        if (data[widget.languageCode] != null) {
          skills[data.id] = data[widget.languageCode];
        }
      });

      _selectedSkills = widget.selectedSkills;

      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 8),
          TypeAheadField<SuggestedItem>(
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            errorBuilder: (context, err) {
              return Text(S.of(context).error_was_thrown);
            },
            debounceDuration: Duration(milliseconds: 600),
            hideOnError: true,
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
              skills.forEach((k, v) => dataCopy.add(SuggestedItem()
                ..suggestionMode = SuggestionMode.FROM_DB
                ..suggesttionTitle = v));
              dataCopy.retainWhere(
                (s) => s.suggesttionTitle.toLowerCase().contains(
                      pattern.toLowerCase(),
                    ),
              );

              if (pattern.length > 2 &&
                  !dataCopy
                      .contains(SuggestedItem()..suggesttionTitle = pattern)) {
                var spellCheckResult =
                    await SpellCheckManager.evaluateSpellingFor(pattern,
                        language: widget.languageCode);
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
            noItemsFoundBuilder: (context) {
              return searchUserDefinedEntity(
                keyword: _textEditingController.text,
                language: widget.languageCode,
                showLoader: false,
              );
            },
            onSuggestionSelected: (SuggestedItem suggestion) {
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
              if (!_selectedSkills.containsValue(suggestion.suggesttionTitle)) {
                controller.close();
                String id = skills.keys.firstWhere(
                    (k) => skills[k] == suggestion.suggesttionTitle);
                _selectedSkills[id] = suggestion.suggesttionTitle;
                widget.onSelectedSkillsMap(_selectedSkills);

                setState(() {});
              }
            },
          ),
          SizedBox(height: 20),
          !isDataLoaded
              ? LoadingIndicator()
              : Wrap(
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
                                  String id = skills.keys
                                      .firstWhere((k) => skills[k] == value);
                                  _selectedSkills.remove(id);
                                  setState(() {});
                                },
                              ),
                      )
                      .toList(),
                ),
        ],
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
          return showLoader ? getLoading : LinearProgressIndicator();
        }

        return getSuggestionLayout(
          suggestion: keyword,
          suggestionMode: suggestionMode,
          add: S.of(context).add + ' ',
        );
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
