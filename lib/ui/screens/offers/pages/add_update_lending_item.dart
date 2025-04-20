import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/amenities_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';

import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/add_update_item_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dose_text_field.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/full_screen_widget.dart';

class AddUpdateLendingItem extends StatefulWidget {
  final LendingModel? lendingModel;
  final String? enteredTitle;
  final Function(LendingModel lendingModel)? onItemCreateUpdate;

  AddUpdateLendingItem(
      {this.lendingModel, this.onItemCreateUpdate, this.enteredTitle});

  @override
  _AddUpdateLendingItemState createState() => _AddUpdateLendingItemState();
}

class _AddUpdateLendingItemState extends State<AddUpdateLendingItem> {
  final _formKey = GlobalKey<DoseFormState>();
  List<AmenitiesModel> amenitiesList = [];
  List<String> imagesList = [];
  AddUpdateItemBloc _bloc = AddUpdateItemBloc();
  FocusNode _itemName = FocusNode();
  FocusNode _estimatedValue = FocusNode();
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _estimatedValueController = TextEditingController();
  bool shouldPop = true;

  @override
  void initState() {
    super.initState();
    if (widget.lendingModel != null) {
      _bloc.loadData(widget.lendingModel!.lendingItemModel!);
      _itemNameController.text =
          widget.lendingModel!.lendingItemModel!.itemName!;
      _bloc
          .onPlaceNameChanged(widget.lendingModel!.lendingItemModel!.itemName!);

      _estimatedValueController.text =
          widget.lendingModel!.lendingItemModel!.estimatedValue.toString();
      _bloc.onEstimatedValueChanged(
          widget.lendingModel!.lendingItemModel!.estimatedValue.toString());
    } else {
      if (widget.enteredTitle != null) {
        _itemNameController.text = widget.enteredTitle!;
        _bloc.onPlaceNameChanged(widget.enteredTitle!);
      }
    }
    setState(() {});
    _bloc.message.listen((event) {
      if (event.isNotEmpty && event != null) {
        //hideProgress();
        if (event == 'amenities') {
          showScaffold(S.of(context).validation_error_amenities);
        } else if (event == 'create') {
          showScaffold(S.of(context).creating_item);
        } else if (event == 'update') {
          showScaffold(S.of(context).updating_item);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).add_new_item,
          style: TextStyle(fontSize: 18, fontFamily: 'Europa'),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<Object>(
          stream: _bloc.status,
          builder: (context, status) {
            if (status.data == Status.COMPLETE) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onItemCreateUpdate!(_bloc.getLendingItemModel());
                if (shouldPop) {
                  shouldPop = false;
                  Navigator.pop(context);
                }
              });
            }

            if (status.data == Status.LOADING) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.lendingModel == null
                            ? S.of(context).creating_item
                            : S.of(context).updating_item,
                      ),
                    ),
                  );
                },
              );
            }

            if (status.data == Status.ERROR) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.lendingModel == null
                            ? S.of(context).creating_item_error
                            : S.of(context).updating_item_error,
                      ),
                    ),
                  );
                },
              );
            }
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30.0),
                child: DoseForm(
                  formKey: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<String>(
                        stream: _bloc.itemName,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _itemNameController,
                            focusNode: _itemName,
                            nextNode: null,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateName(val!);
                              return validate == null
                                  ? null
                                  : getAddItemValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).name_of_item}*",
                            onChanged: (String value) {
                              _bloc.onPlaceNameChanged(value);
                              // title = value;
                            },
                            hint: S.of(context).name_of_item_hint,
                            maxLength: 30,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      //ESTIMATED VALUE FIELD HERE
                      StreamBuilder<String>(
                        stream: _bloc.estimatedValue,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.attach_money),
                                errorText: getAddItemValidationError(
                                    context, snapshot.error! as String),
                                hintText: S
                                        .of(context)
                                        .estimated_value_item_hint +
                                    S.of(context).estimated_value_hint_item),
                            controller: _estimatedValueController,
                            focusNode: _estimatedValue,
                            validator: (val) {
                              var validate = _bloc.validateEstimatedVal(val!);
                              return validate == null
                                  ? null
                                  : getAddItemValidationError(
                                      context, validate);
                            },
                            value: snapshot.data.toString(),
                            heading: "${S.of(context).estimated_value}",
                            onChanged: (String value) {
                              _bloc.onEstimatedValueChanged(value);
                              // title = value;
                            },
                            formatters: [
                              FilteringTextInputFormatter.allow(
                                  Regex.numericRegex)
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return ImagePickerDialogMobile(
                                    imagePickerType:
                                        ImagePickerType.LENDING_OFFER,
                                    onLinkCreated: (link) {
                                      imagesList.add(link);
                                      _bloc.onItemImageAdded(imagesList);
                                    },
                                    storeImageFile: (file) {},
                                    storPdfFile: (file) {},
                                    color: Theme.of(context).primaryColor,
                                  );
                                });
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        defaultCameraImageURL,
                                      ),
                                      fit: BoxFit.cover),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(75.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 7.0, color: Colors.black12)
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<List<String>>(
                        stream: _bloc.itemImages,
                        builder: (builder, snapshot) {
                          // if (snapshot.connectionState == ConnectionState.waiting) {
                          //   return LoadingIndicator();
                          // }
                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              !snapshot.hasData) {
                            return Container();
                          }
                          imagesList = snapshot.data as List<String>;
                          return Container(
                            height: 100,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                imagesList.length,
                                (index) => Container(
                                  width: 80,
                                  height: 80,
                                  margin: EdgeInsets.only(left: 5),
                                  child: Stack(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return FullScreenImage(
                                                  imageUrl: imagesList[index],
                                                );
                                              });
                                        },
                                        child: Container(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  imagesList[index])),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            imagesList.removeAt(index);
                                            _bloc.onItemImageAdded(imagesList);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.transparent,
                                            ),
                                            child: Icon(
                                              Icons.cancel_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Container(
                          height: 50,
                          width: 200,
                          child: CustomElevatedButton(
                            color: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            elevation: 3.0,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var connResult =
                                    await Connectivity().checkConnectivity();
                                if (connResult == ConnectivityResult.none) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(S.of(context).check_internet),
                                      action: SnackBarAction(
                                        label: S.of(context).dismiss,
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar(),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (imagesList == null ||
                                    imagesList.length == 0) {
                                  showAlertMessage(
                                      context: context,
                                      message: 'Add images to item');
                                } else {
                                  if (widget.lendingModel == null) {
                                    _bloc.createLendingOfferPlace(
                                        creator:
                                            SevaCore.of(context).loggedInUser);
                                  } else {
                                    _bloc.updateLendingOfferPlace(
                                        model: widget.lendingModel);
                                  }
                                }
                              }
                            },
                            shape: StadiumBorder(),
                            child: Text(
                                widget.lendingModel == null
                                    ? S.of(context).add_item_text
                                    : S.of(context).update_item,
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  void showScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _estimatedValueController.dispose();
    _bloc.dispose();
    _itemName.dispose();
    _estimatedValue.dispose();
    super.dispose();
  }
}

void showAlertMessage({BuildContext? context, String? message}) {
  showDialog(
    context: context!,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(S.of(context).alert),
        content: Text(message!),
        actions: [
          CustomTextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                S.of(context).ok,
                style: TextStyle(color: Colors.deepOrange),
              )),
        ],
      );
    },
  );
}
