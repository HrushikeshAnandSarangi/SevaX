import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/request/widgets/skills_for_requests_widget.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_request/request_enums.dart';
import 'package:sevaexchange/views/exchange/request_utils.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class TimeRequest extends StatefulWidget {
  final AsyncSnapshot<TimebankModel> snapshot;
  final List<ProjectModel> projectModelList;
  final RequestModel requestModel;
  final bool isOfferRequest;
  final OfferModel offer;
  final Function onDescriptionChanged;
  final Widget addToProjectContainer;
  GeoFirePoint location;
  String selectedAddress;
  Widget categoryWidget;

  TimeRequest({
    this.snapshot,
    this.projectModelList,
    this.requestModel,
    this.isOfferRequest,
    this.offer,
    this.selectedAddress,
    this.onDescriptionChanged,
    this.addToProjectContainer,
    this.location,
    this.categoryWidget
  });

  @override
  _TimeRequestState createState() => _TimeRequestState();
}

class _TimeRequestState extends State<TimeRequest> {
  final _debouncer = Debouncer(milliseconds: 500);
  final profanityDetector = ProfanityDetector();
  String categoryMode;
  Map<String, dynamic> _selectedSkillsMap = {};
  bool createEvent = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      RepeatWidget(),

      SizedBox(height: 20),

      Text(
        "${S.of(context).request_description}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          if (value != null && value.length > 5) {
            _debouncer.run(() {
              // getCategoriesFromApi(value);
              widget.onDescriptionChanged(value);
            });
          }
          updateExitWithConfirmationValue(context, 9, value);
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorMaxLines: 2,
          hintText: widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
              ? S.of(context).request_descrip_hint_text
              : S.of(context).request_description_hint,
          hintStyle: hintTextStyle,
        ),
        initialValue: widget.offer != null && widget.isOfferRequest
            ? getOfferDescription(
                offerDataModel: widget.offer,
              )
            : "",
        keyboardType: TextInputType.multiline,
        maxLines: 1,
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_general_text;
          }
          if (profanityDetector.isProfaneString(value)) {
            return S.of(context).profanity_text_alert;
          }
          widget.requestModel.description = value;
        },
      ),

      SizedBox(height: 20),
      // Choose Category and Sub Category
      widget.categoryWidget,
      SizedBox(height: 20),
      Text(
        S.of(context).provide_skills,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      SkillsForRequests(
        languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
        selectedSkills: _selectedSkillsMap,
        onSelectedSkillsMap: (skillMap) {
          if (skillMap.values != null && skillMap.values.length > 0) {
            _selectedSkillsMap = skillMap;
            // setState(() {});
          }
        },
      ),

      SizedBox(height: 20),
      SizedBox(height: 20),
      Text(
        S.of(context).max_credits,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              onChanged: (v) {
                updateExitWithConfirmationValue(context, 10, v);
                if (v.isNotEmpty && int.parse(v) >= 0) {
                  widget.requestModel.maxCredits = int.parse(v);
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                hintText: widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
                    ? S.of(context).onetomanyrequest_participants_or_credits_hint
                    : S.of(context).max_credit_hint,
                hintStyle: hintTextStyle,
                // labelText: 'No. of volunteers',
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return S.of(context).enter_max_credits;
                } else if (int.parse(value) < 0) {
                  return S.of(context).enter_max_credits;
                } else if (int.parse(value) == 0) {
                  return S.of(context).enter_max_credits;
                } else {
                  widget.requestModel.maxCredits = int.parse(value);
                  setState(() {});
                  return null;
                }
              },
            ),
          ),
          infoButton(
            context: context,
            key: GlobalKey(),
            type: InfoType.MAX_CREDITS,
          ),
        ],
      ),
      SizedBox(height: 20),
      widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
          ? Text(
              S.of(context).total_no_of_participants,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            )
          : Text(
              S.of(context).number_of_volunteers,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            ),
      TextFormField(
        onChanged: (v) {
          updateExitWithConfirmationValue(context, 11, v);
          if (v.isNotEmpty && int.parse(v) >= 0) {
            widget.requestModel.numberOfApprovals = int.parse(v);
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintText: widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
              ? S.of(context).onetomanyrequest_participants_or_credits_hint
              : S.of(context).number_of_volunteers,
          hintStyle: hintTextStyle,
          // labelText: 'No. of volunteers',
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_volunteer_count;
          } else if (int.parse(value) < 0) {
            return S.of(context).validation_error_volunteer_count_negative;
          } else if (int.parse(value) == 0) {
            return S.of(context).validation_error_volunteer_count_zero;
          } else {
            widget.requestModel.numberOfApprovals = int.parse(value);
            setState(() {});
            return null;
          }
        },
      ),
      CommonUtils.TotalCredits(
        context: context,
        requestModel: widget.requestModel,
        requestCreditsMode: TotalCreditseMode.CREATE_MODE,
      ),
      SizedBox(height: 15),
      AddImagesForRequest(
        onLinksCreated: (List<String> imageUrls) {
          widget.requestModel.imageUrls = imageUrls;
        },
      ),
      Center(
        child: LocationPickerWidget(
          selectedAddress: widget.selectedAddress,
          location: widget.location,
          onChanged: (LocationDataModel dataModel) {
            log("received data model");
            setState(() {
              widget.location = dataModel.geoPoint;
              widget.selectedAddress = dataModel.location;
            });
          },
        ),
      )
    ]);
  }
}
