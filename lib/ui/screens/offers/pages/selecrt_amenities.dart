import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/amenities_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

typedef MapListCallback = void Function(
    Map<String, dynamic> _selectedAmenitiesMap);

class SelectAmenities extends StatefulWidget {
  final String? languageCode;
  final Map<String, dynamic>? selectedAmenities;
  final MapListCallback? onSelectedAmenitiesMap;

  SelectAmenities(
      {this.languageCode, this.selectedAmenities, this.onSelectedAmenitiesMap});

  @override
  _SelectAmenitiesState createState() => _SelectAmenitiesState();
}

class _SelectAmenitiesState extends State<SelectAmenities> {
  Map<String, dynamic> amenities = {};
  Map<String, dynamic> _selectedAmenities = {};
  bool isDataLoaded = false;
  bool hasPellError = false;
  TextEditingController _textEditingController = TextEditingController();
  SuggestionsController controller = SuggestionsController();

  @override
  void initState() {
    CollectionRef.amenities.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.id);
        if (data['title_' + widget.languageCode!] != null) {
          amenities[data['id']] = data['title_' + widget.languageCode!];
        } else {
          amenities[data['id']] = data['title_en'];
        }
      });

      _selectedAmenities = widget.selectedAmenities!;

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
            suggestionsController: SuggestionsController(),
            errorBuilder: (context, err) {
              return Text(S.of(context).error_was_thrown);
            },
            debounceDuration: Duration(milliseconds: 600),
            hideOnError: true,
            builder: (context, textEditingController, focusNode) {
              return TextField(
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
              );
            },
            // scrollController: controller,
            suggestionsCallback: (pattern) async {
              List<SuggestedItem> dataCopy = [];
              amenities.forEach((k, v) => dataCopy.add(SuggestedItem()
                ..suggestionMode = SuggestionMode.FROM_DB
                ..suggesttionTitle = v));
              dataCopy.retainWhere(
                (s) => s.suggesttionTitle.toLowerCase().contains(
                      pattern.toLowerCase(),
                    ),
              );

              // if (pattern.length > 2 &&
              //     !dataCopy
              //         .contains(SuggestedItem()..suggesttionTitle = pattern)) {
              //   var spellCheckResult =
              //       await SpellCheckManager.evaluateSpellingFor(pattern,
              //           language: widget.languageCode);
              //   if (spellCheckResult.hasErros) {
              //     dataCopy.add(SuggestedItem()
              //       ..suggestionMode = SuggestionMode.USER_DEFINED
              //       ..suggesttionTitle = pattern);
              //   } else if (spellCheckResult.correctSpelling != pattern) {
              //     dataCopy.add(SuggestedItem()
              //       ..suggestionMode = SuggestionMode.SUGGESTED
              //       ..suggesttionTitle = spellCheckResult.correctSpelling);
//
              //     dataCopy.add(SuggestedItem()
              //       ..suggestionMode = SuggestionMode.USER_DEFINED
              //       ..suggesttionTitle = pattern);
              //   } else {
              //     dataCopy.add(SuggestedItem()
              //       ..suggestionMode = SuggestionMode.USER_DEFINED
              //       ..suggesttionTitle = pattern);
              //   }
              // }

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

                // case SuggestionMode.SUGGESTED:
                //   if (ProfanityDetector()
                //       .isProfaneString(suggestedItem.suggesttionTitle)) {
                //     return ProfanityDetector.getProanityAdvisory(
                //       suggestion: suggestedItem.suggesttionTitle,
                //       suggestionMode: SuggestionMode.USER_DEFINED,
                //       context: context,
                //     );
                //   }
                //   return searchUserDefinedEntity(
                //     keyword: suggestedItem.suggesttionTitle,
                //     language: widget.languageCode,
                //     suggestionMode: suggestedItem.suggestionMode,
                //     showLoader: true,
                //   );
//
                // case SuggestionMode.USER_DEFINED:
                //   if (ProfanityDetector()
                //       .isProfaneString(suggestedItem.suggesttionTitle)) {
                //     return ProfanityDetector.getProanityAdvisory(
                //       suggestion: suggestedItem.suggesttionTitle,
                //       suggestionMode: SuggestionMode.USER_DEFINED,
                //       context: context,
                //     );
                //   }
                //   return searchUserDefinedEntity(
                //     keyword: suggestedItem.suggesttionTitle,
                //     language: widget.languageCode,
                //     suggestionMode: suggestedItem.suggestionMode,
                //     showLoader: false,
                //   );
                //   break;

                default:
                  return Container();
              }
            },
            emptyBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).no_result_found,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
              // return searchUserDefinedEntity(
              //   keyword: _textEditingController.text,
              //   language: widget.languageCode,
              //   showLoader: false,
              // );
            },
            onSelected: (SuggestedItem suggestion) {
              if (ProfanityDetector()
                  .isProfaneString(suggestion.suggesttionTitle)) {
                return;
              }

              // switch (suggestion.suggestionMode) {
              //   case SuggestionMode.SUGGESTED:
              //     var amenitesId = Uuid().generateV4();
              //     LendingOffersRepo.addAmenitiesToDb(
              //         id: amenitesId,
              //         languageCode: widget.languageCode,
              //         title: suggestion.suggesttionTitle);
              //     amenities[amenitesId] = suggestion.suggesttionTitle;
              //     break;

              //   case SuggestionMode.USER_DEFINED:
              //     var amenitesId = Uuid().generateV4();
              //     LendingOffersRepo.addAmenitiesToDb(
              //         id: amenitesId,
              //         languageCode: widget.languageCode,
              //         title: suggestion.suggesttionTitle);
              //     amenities[amenitesId] = suggestion.suggesttionTitle;
              //     break;

              //   case SuggestionMode.FROM_DB:
              //     break;
              // }

              _textEditingController.clear();
              if (!_selectedAmenities
                  .containsValue(suggestion.suggesttionTitle)) {
                controller.close();
                String id = amenities.keys.firstWhere(
                    (k) => amenities[k] == suggestion.suggesttionTitle);
                _selectedAmenities[id] = suggestion.suggesttionTitle;
                widget.onSelectedAmenitiesMap!(_selectedAmenities);

                setState(() {});
              }
            },
          ),
          SizedBox(height: 20),
          !isDataLoaded
              ? LoadingIndicator()
              : Wrap(
                  spacing: 4.0,
                  children: _selectedAmenities.values
                      .toList()
                      .map(
                        (value) => value == null
                            ? Container()
                            : CustomChipWithTick(
                                label: value,
                                isSelected: true,
                                isHidden: false,
                                onTap: () {
                                  String id = amenities.keys
                                      .firstWhere((k) => amenities[k] == value);
                                  _selectedAmenities.remove(id);
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
          context: context,
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
