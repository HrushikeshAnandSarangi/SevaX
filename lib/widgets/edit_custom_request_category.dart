import 'dart:async';
import 'package:universal_io/io.dart' as io;

import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:rxdart/rxdart.dart';

class EditRequestCustomCategory extends StatefulWidget {
  final CategoryModel categoryModel;
  final VoidCallback onCategoryEdited;
  final Color primaryColor;
  final UserModel userModel;

  const EditRequestCustomCategory({
    Key? key,
    required this.categoryModel,
    required this.onCategoryEdited,
    required this.primaryColor,
    required this.userModel,
  });

  @override
  _EditRequestCustomCategoryState createState() =>
      _EditRequestCustomCategoryState();
}

class _EditRequestCustomCategoryState extends State<EditRequestCustomCategory> {
  String subcategorytitle = '';
  String? newRequestCategoryLogo;
  final formKey = GlobalKey<DoseFormState>();
  String? errTxt = '';
  final _subcategorytitleStream = StreamController<String>();
  TextEditingController searchTextController = TextEditingController();
  TextEditingController subcategoryController = TextEditingController();
  FocusNode subcategoryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      subcategorytitle = widget.categoryModel.getCategoryName(context);
    });
    subcategoryController.text =
        widget.categoryModel.getCategoryName(context).toString();
    //For Checking Duplicate request subcategory When creating new one
    searchTextController.addListener(
        () => _subcategorytitleStream.add(searchTextController.text));
    _subcategorytitleStream.stream
        .debounceTime(Duration(milliseconds: 400))
        .forEach((s) {
      logger.e("Text updates============ $s");
      if (s.isEmpty) {
        setState(() {});
      } else {
        SearchManager.searchRequestCategoriesForDuplicate(
                queryString: s.trim(), context: context)
            .then((categoryFound) {
          if (categoryFound) {
            setState(() {
              errTxt = S.of(context).request_category_exists;
            });
            logger.e('DUPLICATE FOUND');
          } else {
            setState(() {
              // groupFound = false;
              errTxt = null;
            });
            logger.e('NO DUPLICATES');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context1, setState) {
        return AlertDialog(
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          title: Row(
            children: [
              InkWell(
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                ),
                onTap: () {
                  Navigator.of(context1).pop();
                },
              ),
              SizedBox(width: 12),
              Text(
                S.of(context).edit_request_category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Container(
            height: 182,
            width: 285,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // height: 45,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {},
                    leading: Icon(Icons.add_circle_outline, size: 16),
                    title: DoseForm(
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      formKey: formKey,
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        child: DoseTextField(
                          isRequired: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          focusNode: subcategoryFocusNode,
                          controller: subcategoryController,
                          onChanged: (val) {
                            subcategorytitle = val;
                            _subcategorytitleStream.add(val);
                            errTxt = '';
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                left: 0.0, right: 8.0, bottom: 10.0),
                            border: InputBorder.none,
                            hintText:
                                S.of(context).add_new_subcategory_hint + '*',
                            hintStyle: TextStyle(color: Colors.grey),
                            errorStyle: TextStyle(height: 0.85),
                            // errorText: errTxt,
                          ),
                          validator: (value) {
                            final profanityDetector = ProfanityDetector();
                            if (value == '') {
                              return S.of(context).please_enter_title;
                            }
                            if (errTxt != null) {
                              return errTxt;
                            }
                            if (profanityDetector.isProfaneString(value!) ==
                                true) {
                              return S.of(context).profanity_text_alert;
                            } else {
                              subcategorytitle = value!;
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // height: 45,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return ImagePickerDialogMobile(
                              imagePickerType: ImagePickerType.PROJECT,
                              storeImageFile: (io.File file) => true,
                              storPdfFile: (io.File file) => false,
                              color: widget.primaryColor,
                              onLinkCreated: (link) {
                                newRequestCategoryLogo = link;
                                if (this.mounted) {
                                  setState(() {});
                                }
                                ;
                                logger.e('NEW LOGO CHECK: ' +
                                    newRequestCategoryLogo.toString());
                              },
                            );
                          });
                    },
                    leading: Image.asset(
                      'images/icons/multi_image.png',
                      height: 16,
                    ),
                    title: newRequestCategoryLogo != null
                        ? Text(
                            S.of(context).photo_selected,
                            style: TextStyle(color: Colors.green),
                          )
                        : Text(
                            S.of(context).select_photo,
                            style: TextStyle(color: Colors.grey),
                          ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.032),
                Container(
                  child: Center(
                    child: CustomElevatedButton(
                      color: widget.primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2.0,
                      textColor: Colors.white,
                      onPressed: () async {
                        Map<String, dynamic> newRequestCategoryModel = {
                          'categoryId': widget.categoryModel.categoryId,
                          'logo': newRequestCategoryLogo == null
                              ? widget.categoryModel.logo
                              : newRequestCategoryLogo,
                          'type': 'subCategory',
                          'typeId': widget.categoryModel.typeId,
                          'creatorId': widget.userModel.sevaUserID,
                          'creatorEmail': widget.userModel.email,
                          'title_' +
                              (widget.userModel.language ??
                                  S.of(context).localeName): subcategorytitle
                        };
                        if (newRequestCategoryLogo !=
                                widget.categoryModel.logo &&
                            subcategorytitle ==
                                widget.categoryModel.getCategoryName(context)) {
                          await editRequestCategory(newRequestCategoryModel,
                              widget.categoryModel.typeId ?? '');

                          Navigator.of(context1).pop();
                        }
                        if (formKey.currentState!.validate() &&
                            (errTxt == null || errTxt == "")) {
                          formKey.currentState!.save();
                          //validate title is not empty
                          await editRequestCategory(newRequestCategoryModel,
                              widget.categoryModel.typeId ?? '');
                          Navigator.of(context1).pop();
                          // widget.onCategoryEdited();
                        }
                        ;
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 14, right: 14),
                        child: Text(
                          S.of(context).save,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      shape: StadiumBorder(),
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            Container(height: 0),
          ],
        );
      },
    );
  }

  void dispose() {
    super.dispose();
    _subcategorytitleStream.close();
  }
}
