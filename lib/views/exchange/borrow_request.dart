/*
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class BorrowRequestWidget extends StatelessWidget {
  AsyncSnapshot<TimebankModel> snapshot;
  final List<ProjectModel> projectModelList;

  BorrowRequestWidget({this.snapshot, this.projectModelList});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      RepeatWidget(),
      SizedBox(height: 15),

      RequestDescriptionData(S.of(context).request_descrip_hint_text),
      SizedBox(height: 20),
      //Same hint for Room and Tools ?
      // Choose Category and Sub Category
      InkWell(
        child: Column(
          children: [
            Row(
              children: [
                categoryMode == null
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
                        "${categoryMode}",
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
            selectedCategoryModels != null && selectedCategoryModels.length > 0
                ? Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: _buildselectedSubCategories(),
                  )
                : Container(),
          ],
        ),
        onTap: () => moveToCategory(),
      ),
      SizedBox(height: 20),
      isFromRequest(
        projectId: widget.projectId,
      )
          ? addToProjectContainer(
              snapshot,
              projectModelList,
              requestModel,
            )
          : Container(),

      SizedBox(height: 15),

      Text(
        S.of(context).city + '/' + S.of(context).state,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      SizedBox(height: 10),

      Text(
        L.of(context).provide_address,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.grey,
        ),
      ),
      SizedBox(height: 10),

      Center(
        child: LocationPickerWidget(
          selectedAddress: selectedAddress,
          location: location,
          onChanged: (LocationDataModel dataModel) {
            log("received data model");
            setState(() {
              location = dataModel.geoPoint;
              this.selectedAddress = dataModel.location;
            });
          },
        ),
      )
    ]);
  }

  bool isFromRequest({String projectId}) {
    return projectId == null || projectId.isEmpty || projectId == "";
  }
}
*/
