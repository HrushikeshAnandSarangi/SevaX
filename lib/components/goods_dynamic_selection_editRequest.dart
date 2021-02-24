import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:usage/uuid/uuid.dart';

typedef StringMapCallback = void Function(Map<String, dynamic> goods);

class GoodsDynamicSelection extends StatefulWidget {
  final bool automaticallyImplyLeading;
  Map<String, String> goodsbefore;
  final StringMapCallback onSelectedGoods;

  GoodsDynamicSelection(
      {this.goodsbefore,
      @required this.onSelectedGoods,
      this.automaticallyImplyLeading = true});
  @override
  _GoodsDynamicSelectionState createState() => _GoodsDynamicSelectionState();
}

class _GoodsDynamicSelectionState extends State<GoodsDynamicSelection> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();

  bool autovalidate = false;
  Map<String, String> goods = {};
  Map<String, String> _selectedGoods = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    this._selectedGoods = widget.goodsbefore != null ? widget.goodsbefore : {};
    Firestore.instance
        .collection('donationCategories')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.documentID);
        goods[data.documentID] = data['goodTitle'];

        // ids[data['name']] = data.documentID;
      });
      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            //TODOSUGGESTION
            TypeAheadField<SuggestedItem>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBuilder: (context, err) {
                  return Text(S.of(context).error_occured);
                },
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
                  goods.forEach(
                    (k, v) => dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.FROM_DB
                      ..suggesttionTitle = v),
                  );
                  dataCopy.retainWhere((s) => s.suggesttionTitle
                      .toLowerCase()
                      .contains(pattern.toLowerCase()));
                  if (pattern.length > 2 &&
                      !dataCopy.contains(
                          SuggestedItem()..suggesttionTitle = pattern)) {
                    var spellCheckResult =
                        await SpellCheckManager.evaluateSpellingFor(pattern,
                            language:
                                SevaCore.of(context).loggedInUser.language ??
                                    'en');
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
                          suggestionMode: SuggestionMode.SUGGESTED,
                          context: context,
                        );
                      }
                      return searchUserDefinedEntity(
                        keyword: suggestedItem.suggesttionTitle,
                        language: 'en',
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
                        language: 'en',
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
                    language: 'en',
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
                      var newGoodId = Uuid().generateV4();
                      addGoodsToDb(
                        goodsId: newGoodId,
                        goodsLanguage: 'en',
                        goodsTitle: suggestion.suggesttionTitle,
                      );
                      goods[newGoodId] = suggestion.suggesttionTitle;
                      break;

                    case SuggestionMode.USER_DEFINED:
                      var goodId = Uuid().generateV4();
                      addGoodsToDb(
                        goodsId: goodId,
                        goodsLanguage: 'en',
                        goodsTitle: suggestion.suggesttionTitle,
                      );
                      goods[goodId] = suggestion.suggesttionTitle;
                      break;

                    case SuggestionMode.FROM_DB:
                      break;
                  }
                  // controller.close();

                  _textEditingController.clear();
                  if (!_selectedGoods.containsValue(suggestion)) {
                    controller.close();
                    String id = goods.keys.firstWhere(
                      (k) => goods[k] == suggestion.suggesttionTitle,
                    );
                    _selectedGoods[id] = suggestion.suggesttionTitle;
                    widget.onSelectedGoods(_selectedGoods);
                    setState(() {});
                  }
                }
                // onSuggestionSelected: (suggestion) {
                //   _textEditingController.clear();
                //   if (!_selectedGoods.containsValue(suggestion)) {
                //     controller.close();
                //     String id =
                //         goods.keys.firstWhere((k) => goods[k] == suggestion);
                //     _selectedGoods[id] = suggestion;
                //     widget.onSelectedGoods(_selectedGoods);
                //     setState(() {});
                //   }
                // },
                ),

            SizedBox(height: 20),
            !isDataLoaded
                ? LoadingIndicator()
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Wrap(
                          runSpacing: 5.0,
                          spacing: 5.0,
                          children: _selectedGoods.values
                              .toList()
                              .map(
                                (value) => value == null
                                    ? Container()
                                    : CustomChip(
                                        title: value,
                                        onDelete: () {
                                          String id =
                                              _selectedGoods.keys.firstWhere(
                                            (k) {
                                              return _selectedGoods[k] == value;
                                            },
                                          );
                                          _selectedGoods.remove(id);
                                          widget
                                              .onSelectedGoods(_selectedGoods);
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
          ],
        ));
  }

  // FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
  //   String keyword,
  //   String language,
  // }) {
  //   return FutureBuilder<SpellCheckResult>(
  //     future: SpellCheckManager.evaluateSpellingFor(
  //       keyword,
  //       language: language,
  //     ),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return getLinearLoading;
  //       }

  //       return getSuggestionLayout(
  //         suggestion:
  //             !snapshot.data.hasErros ? snapshot.data.correctSpelling : keyword,
  //       );
  //     },
  //   );
  // }

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
          return showLoader ? getLinearLoading : LinearProgressIndicator();
        }

        return getSuggestionLayout(
          suggestion: keyword,
          suggestionMode: suggestionMode,
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

  static Future<void> addGoodsToDb({
    String goodsId,
    String goodsTitle,
    String goodsLanguage,
  }) async {
    await Firestore.instance
        .collection('donationCategories')
        .document(goodsId)
        .setData(
      {'goodTitle': goodsTitle, 'lang': goodsLanguage},
    );
  }

  Padding getSuggestionLayout({
    String suggestion,
    SuggestionMode suggestionMode,
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
                            text: S.of(context).add + ' ',
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
          )),
    );
  }
  // Padding getSuggestionLayout({
  //   String suggestion,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.all(18.0),
  //     child: GestureDetector(
  //       onTap: () async {
  //         _textEditingController.clear();
  //         controller.close();
  //         var goodsId = Uuid().generateV4();
  //         await addGoodsToDb(
  //           goodsId: goodsId,
  //           goodsLanguage: 'en',
  //           goodsTitle: suggestion,
  //         );
  //         goods[goodsId] = suggestion;

  //         if (!_selectedGoods.containsValue(suggestion)) {
  //           controller.close();
  //           String id = goods.keys.firstWhere((k) => goods[k] == suggestion);
  //           _selectedGoods[id] = suggestion;
  //           setState(() {});
  //         }
  //       },
  //       child: Container(
  //           height: 40,
  //           alignment: Alignment.centerLeft,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "${S.of(context).add.toUpperCase()} \"${suggestion}\"",
  //                       style: TextStyle(fontSize: 16, color: Colors.blue),
  //                     ),
  //                     Text(
  //                       S.of(context).no_data,
  //                       style: TextStyle(fontSize: 16, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Icon(
  //                 Icons.add,
  //                 color: Colors.grey,
  //               ),
  //             ],
  //           )),
  //     ),
  //   );
  // }
}