import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

class SelectLendingPlace extends StatefulWidget {
  final Function(LendingPlaceModel) onSelected;

  const SelectLendingPlace({
    Key key,
    this.onSelected,
  }) : super(key: key);
  @override
  _SelectLendingPlaceState createState() => _SelectLendingPlaceState();
}

class _SelectLendingPlaceState extends State<SelectLendingPlace> {
  LendingPlaceModel selectedModel = LendingPlaceModel();
  // List<CommunityCategoryModel> availableCategories = [];
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  Future<List<LendingPlaceModel>> future;
  bool isDataLoaded = false;
  @override
  void initState() {
    future = LendingOffersRepo.getAllLendingPlaces();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return LoadingIndicator();
              }
              return TypeAheadField<LendingPlaceModel>(
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
                itemBuilder: (BuildContext context, itemData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      itemData.placeName,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  widget.onSelected(suggestion);
                },
                suggestionsCallback: (String pattern) async {
                  // if (availableCategories.isEmpty) {
                  //   availableCategories =
                  //       await CommunityRepository.getCommunityCategories();
                  // }
                  var dataCopy = List<LendingPlaceModel>.from(snapshot.data);
                  dataCopy
                      .retainWhere((s) => s.placeName.toLowerCase().contains(
                            pattern.toLowerCase(),
                          ));
                  return dataCopy;
                },
              );
            }),
        SizedBox(height: 4),
      ],
    );
  }
}
