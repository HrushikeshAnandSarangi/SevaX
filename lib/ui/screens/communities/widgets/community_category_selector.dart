import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

class CommunityCategorySelector extends StatefulWidget {
  final List<String>? selectedCategories;
  final ValueChanged<List<CommunityCategoryModel>>? onChanged;

  const CommunityCategorySelector({
    Key? key,
    this.onChanged,
    this.selectedCategories,
  }) : super(key: key);
  @override
  _CommunityCategorySelectorState createState() =>
      _CommunityCategorySelectorState();
}

class _CommunityCategorySelectorState extends State<CommunityCategorySelector> {
  Map<String, CommunityCategoryModel> selectedCateories = {};
  final SuggestionsController<CommunityCategoryModel> controller =
      SuggestionsController<CommunityCategoryModel>();
  final TextEditingController _textEditingController = TextEditingController();
  late final Future<List<CommunityCategoryModel>> future;
  bool isDataLoaded = false;
  @override
  void initState() {
    future = CommunityRepository.getCommunityCategories();
    if (widget.selectedCategories?.isNotEmpty ?? false) {
      widget.selectedCategories?.forEach((element) {
        // selectedCateories[element.id] = element;
      });
    }
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
              if (!isDataLoaded) {
                widget.selectedCategories?.forEach((element) {
                  selectedCateories[element] = (snapshot.data
                          as List<CommunityCategoryModel>)
                      .firstWhere((e) => element == e.id, orElse: () => null!);
                  isDataLoaded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {});
                });
              }
              return TypeAheadField<CommunityCategoryModel>(
                onSelected: (suggestion) {
                  selectedCateories[suggestion.id] = suggestion;
                  widget.onChanged?.call(selectedCateories.values.toList());
                  setState(() {});
                },
                errorBuilder: (context, err) {
                  return Text(S.of(context).error_occured);
                },
                hideOnError: true,
                builder: (context, controller, focusNode) => TextField(
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
                        controller.clear();
                      },
                    ),
                  ),
                ),
                suggestionsController: controller,
                itemBuilder: (BuildContext context, itemData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      itemData.getCategoryName(context),
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                // onSuggestionSelected: (suggestion) {
                //   selectedCateories[suggestion.id] = suggestion;
                //   widget.onChanged(selectedCateories.values.toList());
                //   setState(() {});
                // },
                // onSelected: (suggestion) {
                //   // You can keep this the same as onSuggestionSelected or customize as needed
                //   selectedCateories[suggestion.id] = suggestion;
                //   widget.onChanged(selectedCateories.values.toList());
                //   setState(() {});
                // },
                suggestionsCallback: (String pattern) async {
                  // if (availableCategories.isEmpty) {
                  //   availableCategories =
                  //       await CommunityRepository.getCommunityCategories();
                  // }
                  var dataCopy = List<CommunityCategoryModel>.from(
                      snapshot.data as List<CommunityCategoryModel>);
                  dataCopy.retainWhere(
                    (s) =>
                        s.getCategoryName(context).toLowerCase().contains(
                              pattern.toLowerCase(),
                            ) &&
                        !selectedCateories.containsKey(s.id),
                  );
                  return dataCopy;
                },
              );
            }),
        SizedBox(height: 4),
        Wrap(
          runSpacing: 4,
          spacing: 4,
          children: selectedCateories.values
              .map(
                (data) => CustomChip(
                  title: data.getCategoryName(context),
                  onDelete: () {
                    setState(() {
                      selectedCateories.remove(data.id);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
