import 'package:flutter/material.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  bool isExpanded = false;
  bool _isSearching = false;
  String selectedCategory = '';
  List<CategoryModel> selectedSubCategories = [];
  List<CategoryModel> categories = [];
  List<CategoryModel> mainCategories = [];
  List<CategoryModel> subCategories = [];
  List<CategoryModel> searchcategories = [];
  List<CategoryModel> searchSubcategories = [];
  TextEditingController _textEditingController = TextEditingController();
  bool dataLoaded = false;
  @override
  void initState() {
    super.initState();
    getCategories();
  }

  Future<void> getCategories() async {
    await FirestoreManager.getAllCategories().then((value) {
      categories = value;
      mainCategories = filterMainCategories(value);
      dataLoaded = true;
      setState(() {});
    });
  }

  // search function
  void filterSearchResults(String query) {
    searchcategories = List<CategoryModel>.from(mainCategories.where(
        (element) =>
            element.title_en.toLowerCase().contains(query.toLowerCase())));
    _isSearching = true;
    setState(() {});
    logger.i("Categories =>\n${searchcategories}");
  }

  @override
  Widget build(BuildContext context) {
    logger.i('selectedCategory =>  ${selectedCategory}');
    logger.i('selectedSubCategories =>  ${selectedSubCategories}');
    var color = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Category"),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Future.delayed(Duration.zero, () {
                Navigator.pop(
                    context, [selectedCategory, selectedSubCategories]);
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
                          hintText: "Search Category",
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
                    Expanded(
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
                                  accentColor: color,
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    '${!_isSearching ? mainCategories[ind].title_en : searchcategories[ind].title_en}',
                                  ),
                                  onExpansionChanged: (bool expanding) {
                                    if (true) {
                                      selectedCategory = !_isSearching
                                          ? mainCategories[ind].title_en
                                          : searchcategories[ind].title_en;
                                      this.isExpanded = expanding;
                                      setState(() {});
                                    }
                                  },
                                  children: subCategoryWidgets(!_isSearching
                                      ? mainCategories[ind].typeId
                                      : searchcategories[ind].typeId),
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
                  child: Text('No categories Available'),
                ),
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
          child: CheckboxListTile(
            title: Text(subs[index].title_en ?? '',
                style: TextStyle(color: Colors.black)),
            value: selectedSubCategories.contains(subs[index]),
            onChanged: (value) {
              if (value) {
                selectedSubCategories.add(subs[index]);
              } else {
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
    ).toList();
  }

  List<CategoryModel> filterMainCategories(List<CategoryModel> mainCategories) {
    List<CategoryModel> filteredList = [];
    filteredList = List<CategoryModel>.from(mainCategories
        .where((element) => element.type == CategoryType.CATEGORY));

    return filteredList;
  }
}
