import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/ui/screens/request/widgets/edit_request_category_card.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CustomRequestCategories extends StatefulWidget {
  @override
  _CustomRequestCategoriesState createState() =>
      _CustomRequestCategoriesState();
}

class _CustomRequestCategoriesState extends State<CustomRequestCategories> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).my_request_categories,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: customRequestCategoriesWidget,
            ),
          ],
        ),
      ),
    );
  }

  Widget get customRequestCategoriesWidget {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<Object>(
                stream: getUserCreatedRequestCategories(
                    SevaCore.of(context).loggedInUser.sevaUserID!, context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingIndicator();
                  }
                  List<CategoryModel> categoryModelList =
                      snapshot.data! as List<CategoryModel>;

                  return categoryModelList.length == 0
                      ? Center(
                          child: Text(
                          S.of(context).no_subcategories_created,
                          style:
                              TextStyle(fontSize: 17, color: Colors.grey[400]),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: categoryModelList.length,
//            controller: _scrollController,
                          itemBuilder: (context, index) {
                            return EditRequestCategoryCard(
                              categoryModel: categoryModelList[index],
                              userModel: SevaCore.of(context).loggedInUser,
                            );
                          });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
