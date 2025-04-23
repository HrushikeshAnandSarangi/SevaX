import 'dart:async';
import 'package:universal_io/io.dart' as io;
import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:rxdart/rxdart.dart';

class AddNewRequestCategory extends StatefulWidget {
  final String categoryId;
  final VoidCallback onNewCategoryCreated;
  final Color primaryColor;

  const AddNewRequestCategory(
      {Key? key,
      required this.categoryId,
      required this.onNewCategoryCreated,
      required this.primaryColor})
      : super(key: key);

  @override
  _AddNewRequestCategoryState createState() => _AddNewRequestCategoryState();
}

class _AddNewRequestCategoryState extends State<AddNewRequestCategory> {
  String subcategorytitle = '';
  String? newRequestCategoryLogo;
  final formKey = GlobalKey<DoseFormState>();
  String? errTxt = '';
  final _subcategorytitleStream = StreamController<String>();
  TextEditingController searchTextController = TextEditingController();
  FocusNode subcategoryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

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
    return Padding(
      padding: EdgeInsets.only(left: 54, top: 5, bottom: 10),
      child: InkWell(
        child: Text(S.of(context).add_new_request_category,
            style: TextStyle(
              color: widget.primaryColor,
              decoration: TextDecoration.underline,
              fontSize: 16,
              fontFamily: 'Europa',
            )),
        onTap: () {
          //show dialog in UI
          showDialog(
            context: context,
            builder: (BuildContext newCategoryDialog) {
              return StatefulBuilder(builder: (context1, setState) {
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
                          Navigator.of(newCategoryDialog).pop();
                        },
                      ),
                      SizedBox(width: 12),
                      Text(
                        S.of(context).add_new_subcategory,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  content: Container(
                    height: 198, // MediaQuery.of(context).size.width * 0.120,
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
                            onTap: null,
                            // leading: Icon(Icons.add_circle_outline, size: 16),
                            title: DoseForm(
                              // autovalidateMode:
                              //     AutovalidateMode.onUserInteraction,
                              formKey: formKey,
                              // child: SizedBox(
                              //   height: MediaQuery.of(context).size.width * 0.08,
                              child: DoseTextField(
                                isRequired: true,
                                focusNode: subcategoryFocusNode,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: searchTextController,
                                onChanged: (val) {
                                  subcategorytitle = val;
                                  _subcategorytitleStream.add(val);
                                  errTxt = '';
                                  setState(() {});
                                },
                                maxLines: 1,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: 0.0, right: 8.0, bottom: 10.0),
                                  border: InputBorder.none,
                                  hintText:
                                      S.of(context).add_new_subcategory_hint +
                                          '*',
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
                                  if (value != null &&
                                      profanityDetector
                                          .isProfaneString(value)) {
                                    return S.of(context).profanity_text_alert;
                                  } else {
                                    subcategorytitle = value!;
                                    return null;
                                  }
                                },
                              ),
                              // ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.02),
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
                                      color: widget.primaryColor,
                                      storeImageFile: (io.File file) async {
                                        return await file.path;
                                      },
                                      storPdfFile: (io.File file) async => null,
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
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.032),
                        Container(
                          child: Center(
                            child: CustomElevatedButton(
                              color: widget.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              elevation: 2.0,
                              textColor: Colors.white,
                              onPressed: () async {
                                if (formKey.currentState?.validate() == true &&
                                    (errTxt == null || errTxt == "")) {
                                  formKey.currentState?.save();
                                  //Add new request category to db
                                  //validate title is not empty
                                  String newTypeId = utils.Utils.getUuid();
                                  Map<String, dynamic> newRequestCategoryModel =
                                      {
                                    'categoryId': widget.categoryId,
                                    'logo': newRequestCategoryLogo == ''
                                        ? defaultGroupImageURL
                                        : newRequestCategoryLogo,
                                    'type': 'subCategory',
                                    'typeId': newTypeId,
                                    'creatorId': SevaCore.of(context)
                                        .loggedInUser
                                        .sevaUserID,
                                    'creatorEmail':
                                        SevaCore.of(context).loggedInUser.email,
                                    'title_' +
                                            (SevaCore.of(context)
                                                    .loggedInUser
                                                    .language ??
                                                S.of(context).localeName):
                                        subcategorytitle
                                  };

                                  await addNewRequestCategory(
                                          newRequestCategoryModel, newTypeId)
                                      .then((value) {
                                    Navigator.of(newCategoryDialog).pop();
                                  });

                                  // After adding new category to DB refresh the state of this or renaviagate here
                                  widget.onNewCategoryCreated();
                                }
                                ;
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 13, right: 13),
                                child: Text(
                                  S.of(context).save,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(15),
                              // ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Container(height: 0),
                  ],
                );
              });
            },
          );
        },
      ),
    );
  }

  void dispose() {
    super.dispose();
    _subcategorytitleStream.close();
  }
}
