import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/widgets/select_category.dart';

class CategoryWidget extends StatefulWidget {
  final RequestModel requestModel;
  final VoidCallback onDone;
  final List<CategoryModel> initialSelectedCategories;
  final String initialCategoryMode;

  const CategoryWidget({
    Key? key,
    required this.requestModel,
    required this.onDone,
    required this.initialSelectedCategories,
    required this.initialCategoryMode,
  }) : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late List<CategoryModel> selectedCategories;
  late String categoryMode;
  late List<String> selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.initialSelectedCategories);
    categoryMode = widget.initialCategoryMode;
    selectedCategoryIds =
        selectedCategories.map((e) => e.typeId).whereType<String>().toList();
    _syncWithRequestModel();
  }

  void _syncWithRequestModel() {
    widget.requestModel.categories = selectedCategoryIds;
  }

  List<Widget> _buildSelectedSubCategories() {
    final uniqueCategories = selectedCategories
        .fold<Map<String, CategoryModel>>(
          {},
          (map, category) {
            final key = category.typeId;
            if (key != null) map.putIfAbsent(key, () => category);
            return map;
          },
        )
        .values
        .toList();

    return uniqueCategories.map((item) {
      return Padding(
        padding: const EdgeInsets.only(right: 7, bottom: 7),
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.getCategoryName(context),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 3),
                InkWell(
                  onTap: () => _removeCategory(item),
                  child: Icon(
                    Icons.cancel_rounded,
                    color: Colors.grey[100],
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _removeCategory(CategoryModel item) {
    if (item.typeId == null || !selectedCategoryIds.contains(item.typeId))
      return;

    setState(() {
      selectedCategories
          .removeWhere((category) => category.typeId == item.typeId);
      selectedCategoryIds =
          selectedCategories.map((e) => e.typeId).whereType<String>().toList();
      _syncWithRequestModel();
    });

    widget.onDone();
  }

  Future<void> _navigateToCategorySelection() async {
    final result = await Navigator.push<List<dynamic>>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Category(
          selectedSubCategoriesids: selectedCategoryIds,
        ),
      ),
    );

    if (result != null &&
        result.length == 2 &&
        result[0] is String &&
        result[1] is List<CategoryModel>) {
      setState(() {
        categoryMode = result[0] as String;
        selectedCategories = result[1] as List<CategoryModel>;
        selectedCategoryIds = selectedCategories
            .map((e) => e.typeId)
            .whereType<String>()
            .toList();
        _syncWithRequestModel();
      });

      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _navigateToCategorySelection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                categoryMode.isNotEmpty
                    ? categoryMode
                    : S.of(context).choose_category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_outlined, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          if (selectedCategories.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.start,
              children: _buildSelectedSubCategories(),
            ),
        ],
      ),
    );
  }
}
