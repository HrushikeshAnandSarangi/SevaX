library flutter_multiselect;

import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/multi_select/selection_model.dart';

class MultiSelect extends FormField<dynamic> {
  final TimebankModel? timebankModel;
  final UserModel? userModel;
  final Widget? titleText;
  final String? hintText;
  final bool required;
  final String? errorText;
  final dynamic? value;
  final bool? filterable;
  final List? dataSource;
  final bool? admin;
  final String? textField;
  final String? valueField;
  final Function? change;
  final Function? open;
  final Function? close;
  final Widget? leading;
  final Widget? trailing;
  final int? maxLength;
  final Color? inputBoxFillColor;
  final Color? errorBorderColor;
  final Color? enabledBorderColor;
  final String? maxLengthText;
  final Color? maxLengthIndicatorColor;
  final Color? titleTextColor;
  final IconData? selectIcon;
  final Color? selectIconColor;
  final Color? hintTextColor;
  // modal overrides
  final Color? buttonBarColor;
  final String? cancelButtonText;
  final IconData? cancelButtonIcon;
  final Color? cancelButtonColor;
  final Color? cancelButtonTextColor;
  final String? saveButtonText;
  final IconData? saveButtonIcon;
  final Color? saveButtonColor;
  final Color? saveButtonTextColor;
  final String? deleteButtonTooltipText;
  final IconData? deleteIcon;
  final Color? deleteIconColor;
  final Color? selectedOptionsBoxColor;
  final String? selectedOptionsInfoText;
  final Color? selectedOptionsInfoTextColor;
  final IconData? checkedIcon;
  final IconData? uncheckedIcon;
  final Color? checkBoxColor;
  final Color? searchBoxColor;
  final String? searchBoxHintText;
  final Color? searchBoxFillColor;
  final IconData? searchBoxIcon;
  final String? searchBoxToolTipText;
  MultiSelect(
      {FormFieldSetter<dynamic>? onSaved,
      FormFieldValidator<dynamic>? validator,
      this.timebankModel,
      this.userModel,
      dynamic initialValue,
      bool autovalidate = false,
      this.titleText,
      this.titleTextColor,
      this.hintText,
      this.hintTextColor = Colors.grey,
      this.required = false,
      this.errorText,
      this.value,
      this.leading,
      this.filterable = true,
      this.dataSource,
      this.admin,
      this.textField,
      this.valueField,
      this.change,
      this.open,
      this.close,
      this.trailing,
      this.maxLength,
      this.maxLengthText,
      this.maxLengthIndicatorColor = Colors.red,
      this.inputBoxFillColor = Colors.white,
      this.errorBorderColor = Colors.red,
      this.enabledBorderColor = Colors.grey,
      this.selectIcon = Icons.arrow_downward,
      this.selectIconColor,
      this.buttonBarColor,
      this.cancelButtonText,
      this.cancelButtonIcon,
      this.cancelButtonColor,
      this.cancelButtonTextColor,
      this.saveButtonText,
      this.saveButtonIcon,
      this.saveButtonColor,
      this.saveButtonTextColor,
      this.deleteButtonTooltipText,
      this.deleteIcon,
      this.deleteIconColor,
      this.selectedOptionsBoxColor,
      this.selectedOptionsInfoText,
      this.selectedOptionsInfoTextColor,
      this.checkedIcon,
      this.uncheckedIcon,
      this.checkBoxColor,
      this.searchBoxColor,
      this.searchBoxHintText,
      this.searchBoxFillColor,
      this.searchBoxIcon,
      this.searchBoxToolTipText})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidate
                ? AutovalidateMode.always
                : AutovalidateMode.onUserInteraction,
            builder: (FormFieldState<dynamic> state) {
              Widget _buildSelectedOptions(dynamic values, state) {
                Widget selectedOptions = Container();

                if (values != null) {
                  values.forEach((item) {
                    var existingItem = dataSource?.singleWhere((itm) {
                      return itm[valueField] == item;
                    }, orElse: () => null);

                    if (existingItem != null) {
                      selectedOptions = Chip(
                        label: Text(existingItem[textField],
                            overflow: TextOverflow.ellipsis),
                      );
                    } else {
                      selectedOptions = Container();
                    }
                  });
                }
                return selectedOptions;
              }

              return InkWell(
                  onTap: () async {
                    var results = await Navigator.push(
                        state.context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => SelectionModal(
                              title: titleText ?? const SizedBox.shrink(),
                              filterable: filterable ?? true,
                              valueField: valueField ?? '',
                              textField: textField ?? '',
                              dataSource: dataSource ?? [],
                              admin: admin ?? false,
                              values: state.value ?? [],
                              maxLength: maxLength ?? dataSource?.length ?? 0,
                              buttonBarColor: buttonBarColor ?? Colors.white,
                              cancelButtonText: cancelButtonText ?? 'Cancel',
                              cancelButtonIcon: cancelButtonIcon ?? Icons.close,
                              cancelButtonColor:
                                  cancelButtonColor ?? Colors.red,
                              cancelButtonTextColor:
                                  cancelButtonTextColor ?? Colors.white,
                              saveButtonText: saveButtonText ?? 'Save',
                              saveButtonIcon: saveButtonIcon ?? Icons.check,
                              saveButtonColor: saveButtonColor ?? Colors.blue,
                              saveButtonTextColor:
                                  saveButtonTextColor ?? Colors.white,
                              deleteButtonTooltipText:
                                  deleteButtonTooltipText ?? 'Delete',
                              deleteIcon: deleteIcon ?? Icons.delete,
                              deleteIconColor: deleteIconColor ?? Colors.red,
                              selectedOptionsBoxColor:
                                  selectedOptionsBoxColor ?? Colors.grey[200]!,
                              selectedOptionsInfoText:
                                  selectedOptionsInfoText ?? 'Selected Options',
                              selectedOptionsInfoTextColor:
                                  selectedOptionsInfoTextColor ?? Colors.black,
                              checkedIcon: checkedIcon ?? Icons.check_box,
                              uncheckedIcon: uncheckedIcon ??
                                  Icons.check_box_outline_blank,
                              checkBoxColor: checkBoxColor ?? Colors.blue,
                              searchBoxColor:
                                  searchBoxColor ?? Colors.grey[200]!,
                              searchBoxHintText: searchBoxHintText ?? 'Search',
                              searchBoxFillColor:
                                  searchBoxFillColor ?? Colors.white,
                              searchBoxIcon: searchBoxIcon ?? Icons.search,
                              searchBoxToolTipText:
                                  searchBoxToolTipText ?? 'Search'),
                          fullscreenDialog: true,
                        ));
                    if (results != null) {
                      dynamic newValue;
                      if (results.length > 0) {
                        newValue = results;
                      } else {
                        newValue = ['None'];
                      }
                      state.didChange(newValue);
                      if (change != null) {
                        change(newValue);
                      }
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child:
                                  // RichText(
                                  // text:
                                  titleText ?? const SizedBox.shrink(),
//                                 TextSpan(
//                                     text: titleText,
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'Europa',
//                                         fontSize: 16.0,
//                                         color: titleTextColor ??
//                                             Theme.of(state.context)
//                                                 .primaryColor),
//                                     children: [
// //                                  TextSpan(
// //                                    text: required ? ' *' : '',
// //                                    style: TextStyle(
// //                                        color: maxLengthIndicatorColor,
// //                                        fontSize: 16.0),
// //                                  ),
// //                                  TextSpan(
// //                                    text: maxLength != null ? (maxLengthText ?? '(max $maxLength)') : '',
// //                                    style: TextStyle(
// //                                        color: maxLengthIndicatorColor,
// //                                        fontSize: 13.0),
// //                                  )
//                                     ]),
                              // ),
                            ),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   mainAxisSize: MainAxisSize.max,
                            //   children: <Widget>[
                            //     Icon(
                            //       selectIcon,
                            //       color: selectIconColor ??
                            //           Theme.of(state.context).primaryColor,
                            //       size: 30.0,
                            //     )
                            //   ],
                            // )
                          ],
                        ),
                      ),
                      (state.value == null ||
                              state.value == '' ||
                              (state.value != null && state.value.length == 0))
                          ? Container(
                              margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 6.0),
                              child: Text(
                                hintText ?? '',
                                style: TextStyle(
                                  color: hintTextColor,
                                ),
                              ),
                            )
                          : _buildSelectedOptions(state.value, state),
                    ],
                  ));
            });
}
