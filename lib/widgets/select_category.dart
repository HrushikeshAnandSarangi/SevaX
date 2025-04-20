import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/add_new_request_category.dart';

class Category extends StatefulWidget {
  final List<String>? selectedSubCategoriesids;

  Category({
    this.selectedSubCategoriesids,
  });

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  bool isExpanded = false;
  bool _isSearching = false;
  String selectedCategory = '';
  List<CategoryModel> selectedSubCategories = [];
  List<String> selectedSubCategoriesIds = [];
  List<CategoryModel> categories = [];
  List<CategoryModel> mainCategories = [];
  List<CategoryModel> subCategories = [];
  List<CategoryModel> searchcategories = [];
  TextEditingController _textEditingController = TextEditingController();
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  Future<void> getCategories() async {
    Future.delayed(Duration.zero, () async {
      await FirestoreManager.getAllCategories(
              SevaCore.of(context).loggedInUser.language ?? 'en')
          .then((value) {
        categories = value;
        mainCategories = filterMainCategories(value);
        dataLoaded = true;
        if (widget.selectedSubCategoriesids != null &&
            widget.selectedSubCategoriesids!.length > 0) {
          if (widget.selectedSubCategoriesids != null) {
            selectedSubCategoriesIds.addAll(widget.selectedSubCategoriesids!);
          }
          selectedSubCategories = List<CategoryModel>.from(categories.where(
              (element) => selectedSubCategoriesIds.contains(element.typeId)));
        }

        setState(() {});
      });
    });
  }

  // search function
  void filterSearchResults(String query) {
    searchcategories = List<CategoryModel>.from(categories.where((element) =>
        element
            .getCategoryName(context)
            .toLowerCase()
            .contains(query.toLowerCase())));
    //   _isSearching = true;
    setState(() {});
    logger.i("Categories =>\n${searchcategories}");
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(S.of(context).select_category),
        leading: IconButton(
          onPressed: () {
            Future.delayed(Duration.zero, () {
              Navigator.pop(context,
                  [S.of(context).selected_categories, selectedSubCategories]);
            });
            ;
          },
          icon: Icon(Icons.arrow_back, size: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Future.delayed(Duration.zero, () {
                Navigator.pop(
                    context, ['Selected Categories', selectedSubCategories]);
              });
            },
          ),
        ],
      ),
      body: !dataLoaded
          ? LoadingIndicator()
          : categories != null && categories.length > 1
              ? Column(
                  children: [
                    SizedBox(height: 10),
                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: S.of(context).search_category,
                          hintStyle: TextStyle(fontSize: 14),
                          filled: true,
                          fillColor: Colors.grey[100],
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    //list view
                    _textEditingController.text != null &&
                            _textEditingController.text.length > 0
                        ? searchResults()
                        : Expanded(
                            child: Container(
                              color: Colors.white,
                              child: ListView.builder(
                                itemCount: !_isSearching
                                    ? mainCategories.length
                                    : searchcategories.length,
                                itemBuilder: (con, ind) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 0.03)),
                                    child: Theme(
                                      data: ThemeData(
                                        colorScheme: Theme.of(context)
                                            .colorScheme
                                            .copyWith(secondary: color),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          (!_isSearching
                                                  ? mainCategories[ind]
                                                      .getCategoryName(context)
                                                  : searchcategories[ind]
                                                      .getCategoryName(
                                                          context)) ??
                                              'Unknown',
                                        ),
                                        onExpansionChanged: (bool expanding) {
                                          if (true) {
                                            selectedCategory = (!_isSearching
                                                    ? mainCategories[ind]
                                                        .getCategoryName(
                                                            context)
                                                    : searchcategories[ind]
                                                        .getCategoryName(
                                                            context)) ??
                                                'Unknown';
                                            this.isExpanded = expanding;
                                            setState(() {});
                                          }
                                        },
                                        children: subCategoryWidgets(
                                            _isSearching
                                                ? mainCategories[ind].typeId ??
                                                    ''
                                                : searchcategories[ind]
                                                        .typeId ??
                                                    ''),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                )
              : Center(
                  child: Text(S.of(context).no_categories_available),
                ),
    );
  }

  Widget searchResults() {
    List<CategoryModel> subs = [];
    subs = List<CategoryModel>.from(searchcategories
        .where((element) => element.type == CategoryType.SUB_CATEGORY));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subs.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CheckboxListTile(
            title: Text(subs[index].getCategoryName(context) ?? 'Unknown',
                style: TextStyle(color: Colors.black)),
            value: selectedSubCategories.contains(subs[index]),
            onChanged: (value) {
              if (value!) {
                if (subs[index].typeId != null) {
                  selectedSubCategoriesIds.add(subs[index].typeId!);
                }
                selectedSubCategories.add(subs[index]);
              } else {
                selectedSubCategoriesIds.remove(subs[index].typeId);

                selectedSubCategories.remove(subs[index]);
              }
              setState(() {});
            },
            activeColor: Colors.grey[300],
            checkColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }

  List<Widget> subCategoryWidgets(String mainCategoryId) {
    List<CategoryModel> subs = [];
    subs = List<CategoryModel>.from(categories.where((element) =>
        element.categoryId == mainCategoryId &&
        element.type == CategoryType.SUB_CATEGORY));
    return List.generate(
      subs.length,
      (index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: Text(subs[index].getCategoryName(context) ?? '',
                    style: TextStyle(color: Colors.black)),
                value: selectedSubCategories.contains(subs[index]),
                onChanged: (value) {
                  if (value!) {
                    if (subs[index].typeId != null) {
                      selectedSubCategoriesIds.add(subs[index].typeId!);
                    }
                    selectedSubCategories.add(subs[index]);
                  } else {
                    selectedSubCategoriesIds.remove(subs[index].typeId);

                    selectedSubCategories.remove(subs[index]);
                  }
                  setState(() {});
                },
                activeColor: Colors.grey[300],
                checkColor: Colors.black,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              index == subs.length - 1
                  ? AddNewRequestCategory(
                      categoryId: mainCategoryId,
                      onNewCategoryCreated: () {
                        getCategories();
                      },
                      primaryColor: Theme.of(context).primaryColor)
                  : Container(),
            ],
          ),
        );
      },
    ).toList();
  }

  List<CategoryModel> filterMainCategories(List<CategoryModel> mainCategories) {
    List<CategoryModel> filteredList = [];
    filteredList = List<CategoryModel>.from(mainCategories
        .where((element) => element.type == CategoryType.CATEGORY));

    return filteredList;
  }
}
