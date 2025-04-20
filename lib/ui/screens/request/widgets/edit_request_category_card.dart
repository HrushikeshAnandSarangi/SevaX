import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/widgets/edit_custom_request_category.dart';

class EditRequestCategoryCard extends StatelessWidget {
  final CategoryModel categoryModel;
  final UserModel? userModel;

  const EditRequestCategoryCard(
      {Key? key, required this.categoryModel, this.userModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Container(
            height: 50,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              child: AspectRatio(
                aspectRatio: 5 / 4,
                child: Image.network(
                  categoryModel.logo ?? defaultProjectImageURL,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        trailing: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext newCategoryDialog) {
                return EditRequestCustomCategory(
                  categoryModel: categoryModel,
                  onCategoryEdited: () {
                    Navigator.of(context).pop();
                  },
                  primaryColor: Theme.of(context).primaryColor,
                  userModel: userModel!,
                );
              },
            );
          },
          child: Icon(Icons.edit, size: 21, color: Colors.grey),
        ),
        title: Container(
          // width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(categoryModel.getCategoryName(context)),
              // Text(subTitle),
            ],
          ),
        ),
        // subtitle: Text(subTitle),
        // onTap: onTap,
      ),
    );
  }
}
