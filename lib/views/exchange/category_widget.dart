import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/select_category.dart';

class CategoryWidget extends StatefulWidget {
  final RequestModel requestModel;
  final VoidCallback onDone;
  List<CategoryModel> selectedCategoryModels;
  String categoryMode;


  CategoryWidget({this.requestModel, this.onDone, this.selectedCategoryModels, this.categoryMode});

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  List<String> selectedCategoryIds = [];

  List<Widget> _buildselectedSubCategories() {
    List<CategoryModel> subCategories = [];
    subCategories = widget.selectedCategoryModels;
    log('lll l ${subCategories.length}');
    subCategories.forEach((item) {});
    final ids = subCategories.map((e) => e.typeId).toSet();
    subCategories.retainWhere((x) => ids.remove(x.typeId));
    log('lll after ${subCategories.length}');

    List<Widget> selectedSubCategories = [];
    selectedCategoryIds.clear();
    subCategories.forEach((item) {
      selectedCategoryIds.add(item.typeId);
      selectedSubCategories.add(
        Padding(
          padding: const EdgeInsets.only(right: 7, bottom: 7),
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 3.5, bottom: 5, left: 9, right: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${item.getCategoryName(context).toString()}",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(width: 3),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategoryIds.remove(item.typeId);
                        selectedSubCategories.remove(item.typeId);
                        subCategories.removeWhere((category) => category.typeId == item.typeId);
                        widget.requestModel.categories = selectedCategoryIds;
                      });
                    },
                    child: Icon(Icons.cancel_rounded, color: Colors.grey[100], size: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return selectedSubCategories;
  }

  // Navigat to Category class and geting data from the class
  void moveToCategory() async {
    var category = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => Category(selectedSubCategoriesids: selectedCategoryIds)),
    );
    if (category != null) {
      widget.categoryMode = category[0];
      widget.selectedCategoryModels = await updateInformation(category[1]);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("LENGTH ${widget.selectedCategoryModels.length}");
    return InkWell(
      child: Column(
        children: [
          Row(
            children: [
              widget.categoryMode == null
                  ? Text(
                      S.of(context).choose_category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "${widget.categoryMode}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 16,
              ),
            ],
          ),
          SizedBox(height: 20),
          widget.selectedCategoryModels != null && widget.selectedCategoryModels.length > 0
              ? Wrap(
                  alignment: WrapAlignment.start,
                  children: _buildselectedSubCategories(),
                )
              : Container(),
        ],
      ),
      onTap: () => moveToCategory(),
    );
  }
}
