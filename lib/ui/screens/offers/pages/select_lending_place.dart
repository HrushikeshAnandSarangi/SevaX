import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/offers/pages/add_update_lending_item.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/extensions.dart';

import 'add_update_lending_place.dart';

class SelectLendingPlaceItem extends StatefulWidget {
  final Function(LendingModel)? onSelected;
  final LendingType? lendingType;

  const SelectLendingPlaceItem({
    Key? key,
    this.onSelected,
    this.lendingType,
  }) : super(key: key);

  @override
  _SelectLendingPlaceItemState createState() => _SelectLendingPlaceItemState();
}

class _SelectLendingPlaceItemState extends State<SelectLendingPlaceItem> {
  // LendingModel selectedModel = LendingModel();

  // List<CommunityCategoryModel> availableCategories = [];
  SuggestionsController controller = SuggestionsController();
  TextEditingController _textEditingController = TextEditingController();
  FocusNode suggestionFocusNode = FocusNode();
  Future<List<LendingModel>>? itemsFuture;
  Future<List<LendingModel>>? placesFuture;
  bool isDataLoaded = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      itemsFuture = LendingOffersRepo.getAllLendingItemModels(
          creatorId: SevaCore.of(context).loggedInUser.sevaUserID!);
      placesFuture = LendingOffersRepo.getAllLendingPlaces(
          creatorId: SevaCore.of(context).loggedInUser.sevaUserID!);
      // setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('type ${widget.lendingType}');
    return Column(
      children: [
        FutureBuilder(
            future: widget.lendingType == LendingType.ITEM
                ? itemsFuture
                : placesFuture,
            builder: (context, snapshot) {
              if (!isDataLoaded) {
                isDataLoaded = true;

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {});
                });
              }
              return TypeAheadField<LendingModel>(
                suggestionsController: SuggestionsController(),
                errorBuilder: (context, err) {
                  return Text(S.of(context).error_occured);
                },
                hideOnError: true,
                builder: (context, textFieldController, focusNode) {
                  return TextField(
                    focusNode: suggestionFocusNode,
                    controller: _textEditingController,
                    maxLength: 100,
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
                      contentPadding:
                          EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
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
                emptyBuilder: (context) {
                  return getSuggestionLayout(
                    suggestion: _textEditingController.text,
                    add: S.of(context).add + ' ',
                  );
                },
                itemBuilder: (BuildContext context, itemData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.lendingType == LendingType.ITEM
                          ? itemData.lendingItemModel!.itemName!
                          : itemData.lendingPlaceModel!.placeName!,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                onSelected: (LendingModel suggestion) {
                  widget.onSelected?.call(suggestion);
                },
                suggestionsCallback: (String pattern) async {
                  var dataCopy =
                      List<LendingModel>.from(snapshot.data! as List);
                  if (widget.lendingType == LendingType.ITEM) {
                    dataCopy.retainWhere((s) =>
                        s.lendingItemModel!.itemName!.toLowerCase().contains(
                              pattern.toLowerCase(),
                            ));
                  } else {
                    dataCopy.retainWhere((s) =>
                        s.lendingPlaceModel!.placeName!.toLowerCase().contains(
                              pattern.toLowerCase(),
                            ));
                  }
                  return dataCopy;
                },
              );
            }),
        SizedBox(height: 4),
      ],
    );
  }

  Widget getSuggestionLayout({
    String? suggestion,
    String? add,
  }) {
    return suggestion == ''
        ? Padding(padding: const EdgeInsets.all(0))
        : InkWell(
            onTap: () {
              suggestionFocusNode.unfocus();
              _textEditingController.clear();
              if (widget.lendingType == LendingType.ITEM) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AddUpdateLendingItem(
                        lendingModel: null,
                        enteredTitle: suggestion!.firstWordUpperCase(),
                        onItemCreateUpdate: (LendingModel model) {
                          widget.onSelected!(model);
                        },
                      );
                    },
                  ),
                ).then((_) {
                  itemsFuture = LendingOffersRepo.getAllLendingItemModels(
                      creatorId: SevaCore.of(context).loggedInUser.sevaUserID!);
                  setState(() {});
                });
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AddUpdateLendingPlace(
                        lendingModel: null,
                        enteredTitle: suggestion!.firstWordUpperCase(),
                        onPlaceCreateUpdate: (LendingModel model) {
                          widget.onSelected!(model);
                        },
                      );
                    },
                  ),
                ).then((_) {
                  placesFuture = LendingOffersRepo.getAllLendingPlaces(
                      creatorId: SevaCore.of(context).loggedInUser.sevaUserID!);
                  setState(() {});
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 92,
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
                                  text: suggestion,
                                  style: TextStyle(
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
                            S.of(context).no_data,
                            style: TextStyle(
                              fontSize: 14,
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
            ),
          );
  }
}
