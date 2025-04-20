import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

typedef MapListCallback = void Function(
    Map<String, dynamic> _selectedSkillsMap);

class SkillsForRequests extends StatefulWidget {
  final String? languageCode;
  final Map<String, dynamic>? selectedSkills;
  final MapListCallback? onSelectedSkillsMap;

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
  SuggestionsController controller = SuggestionsController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      CollectionRef.skills
          .orderBy('name')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((DocumentSnapshot data) {
          final dataMap = data.data() as Map<String, dynamic>;
          if (dataMap[widget.languageCode!] != null) {
            skills[dataMap['id']] = dataMap[widget.languageCode];
          } else {
            skills[dataMap['id']] = dataMap['name'];
          }
        });

        log("len ${skills.values.length}");
        if (widget.selectedSkills!.values != null) {
          _selectedSkills = widget.selectedSkills!;
        }
        setState(() {
          isDataLoaded = true;
        });
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
            suggestionsController: SuggestionsController(),
            errorBuilder: (context, err) {
              return Text('No result found');
            },
            debounceDuration: Duration(milliseconds: 300),
            builder: (context, textEditingController, focusNode) {
              return TextField(
                onTap: () {
                  controller.open();
                  controller.resize();
                },
                style: hasPellError
                    ? TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationStyle: TextDecorationStyle.wavy,
                        decorationThickness: 3,
                      )
                    : TextStyle(),
                controller: _textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: S.of(context).search,
                  hintStyle: TextStyle(color: Colors.grey),
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
                    color: Colors.black,
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
              );
            },
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

              // return await Future.value(dataCopy);
              return Future.value(dataCopy);
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
                    language: widget.languageCode!,
                    suggestionMode: suggestedItem.suggestionMode,
                    showLoader: true,
                  );

                case SuggestionMode.USER_DEFINED:
                  if (ProfanityDetector()
                      .isProfaneString(_textEditingController.text)) {
                    return ProfanityDetector.getProanityAdvisory(
                      suggestion: _textEditingController.text,
                      suggestionMode: SuggestionMode.USER_DEFINED,
                      context: context,
                    );
                  }
                  // return searchUserDefinedEntity(
                  //   keyword: suggestedItem.suggesttionTitle,
                  //   language: 'en',
                  //   suggestionMode: suggestedItem.suggestionMode,
                  //   showLoader: false,
                  // );
                  return getSuggestionLayout(
                    suggestion: _textEditingController.text,
                    add: S.of(context).add + ' ',
                    suggestionMode: SuggestionMode.USER_DEFINED,
                  );
                  break;

                default:
                  return Container();
              }
            },
            emptyBuilder: (context) {
              return getSuggestionLayout(
                suggestion: _textEditingController.text,
                add: S.of(context).add + ' ',
                suggestionMode: SuggestionMode.USER_DEFINED,
              );
              // return searchUserDefinedEntity(
              //   keyword: _textEditingController.text,
              //   language: 'en',
              //   showLoader: false,
              // );
            },
            onSelected: (SuggestedItem suggestion) async {
              if (ProfanityDetector()
                  .isProfaneString(suggestion.suggesttionTitle)) {
                return;
              }

              switch (suggestion.suggestionMode) {
                case SuggestionMode.SUGGESTED:
                  var skillId = Uuid().generateV4();
                  SkillsAndInterestBloc.addSkillToDb(
                      skillId: skillId,
                      skillLanguage: widget.languageCode!,
                      skillTitle: suggestion.suggesttionTitle);
                  skills[skillId] = suggestion.suggesttionTitle;

                  if (!_selectedSkills
                      .containsValue(suggestion.suggesttionTitle)) {
                    controller.close();
                    String id = skills.keys.firstWhere(
                      (k) => skills[k] == suggestion.suggesttionTitle,
                    );
                    _selectedSkills[id] = suggestion.suggesttionTitle;
                    widget.onSelectedSkillsMap!(_selectedSkills);

                    setState(() {});
                  }
                  break;

                case SuggestionMode.USER_DEFINED:
                  var skillId = Uuid().generateV4();
                  SkillsAndInterestBloc.addSkillToDb(
                    skillId: skillId,
                    skillLanguage: widget.languageCode!,
                    skillTitle: _textEditingController.text,
                  );
                  skills[skillId] = _textEditingController.text;
                  if (!_selectedSkills
                      .containsValue(_textEditingController.text)) {
                    controller.close();
                    String id = skills.keys.firstWhere(
                      (k) => skills[k] == _textEditingController.text,
                    );
                    _selectedSkills[id] = _textEditingController.text;
                    widget.onSelectedSkillsMap!(_selectedSkills);
                    setState(() {});
                  }
                  break;

                case SuggestionMode.FROM_DB:
                  if (!_selectedSkills
                      .containsValue(suggestion.suggesttionTitle)) {
                    controller.close();
                    String id = skills.keys.firstWhere(
                      (k) => skills[k] == suggestion.suggesttionTitle,
                    );
                    _selectedSkills[id] = suggestion.suggesttionTitle;
                    widget.onSelectedSkillsMap!(_selectedSkills);

                    setState(() {});
                  }
                  break;
              }

              _textEditingController.clear();
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

  Padding getSuggestionLayout({
    String? suggestion,
    SuggestionMode? suggestionMode,
    String? add,
  }) {
    return suggestion == ''
        ? Padding(padding: const EdgeInsets.all(0))
        : Padding(
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
                                style: suggestionMode ==
                                        SuggestionMode.SUGGESTED
                                    ? TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      )
                                    : TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.red,
                                        decorationStyle:
                                            TextDecorationStyle.wavy,
                                        decorationThickness: 1.5,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          suggestionMode == SuggestionMode.SUGGESTED
                              ? S.of(context).suggested
                              : S.of(context).you_entered,
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
              ),
            ),
          );
  }
}
