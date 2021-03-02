import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/views/core.dart';

class BorrowRequestFeedbackPage extends StatefulWidget {

  final RequestModel requestModel;

  const BorrowRequestFeedbackPage(
      {Key key, this.requestModel})
      : super(key: key);

  @override
  _BorrowRequestFeedbackPageState createState() =>
      _BorrowRequestFeedbackPageState();
}

class _BorrowRequestFeedbackPageState extends State<BorrowRequestFeedbackPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final subject = ReplaySubject<int>();
  @override
  void initState() {
    subject
        .transform(ThrottleStreamTransformer(
            (_) => TimerStream(true, const Duration(seconds: 1))))
        .listen((data) {
      //checkForReview();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

        ],
       ),
      );

  }

  
        // //Below for testing purpose
        // InkWell(
        //   child: Card(
        //     color: Colors.black,
        //     child: Padding(
        //       padding: const EdgeInsets.all(2.0),
        //       child: Text(
        //         'Borrow Request Feedback',
        //         style: TextStyle(color: Colors.white),
        //       ),
        //     ),
        //   ),
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) =>
        //             BorrowRequestFeedbackPage(requestModel: widget.requestModel),
        //       ),
        //     );
        //   },
        // ),

  //   void checkForReview() async {
  //   int totalMinutes = 0;
  //   var maxClaim;
  //   double creditRequest = 0.0;
  //   log('Borrow Request Feedback Page');

  //   if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
  //       widget.requestModel.selectedInstructor.sevaUserID ==
  //           SevaCore.of(context).loggedInUser.sevaUserID) {

  //     if (selectedHoursPrepTimeController.text == null ||
  //         selectedHoursPrepTimeController.text.length == 0 ||
  //         selectedHoursDeliveryTimeController.text == null ||
  //         selectedHoursDeliveryTimeController.text.length == 0) {
  //       return;
  //     }

  //     totalMinutes = int.parse(selectedMinutesPrepTime) +
  //         int.parse(selectedMinutesDeliveryTime) +
  //         (int.parse(selectedHoursPrepTimeController.text) * 60) +
  //         (int.parse(selectedHoursDeliveryTimeController.text) * 60);
  //   } else if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
  //       widget.requestModel.selectedInstructor.sevaUserID !=
  //           SevaCore.of(context).loggedInUser.sevaUserID) {
  //     logger.i('This 2');

  //     if (hoursController.text == null || hoursController.text.length == 0) {
  //       return;
  //     }

  //      totalMinutes = int.parse(selectedMinuteValue) +
  //         (int.parse(hoursController.text) * 60);
  //   } else {
  //     logger.i('This 3');

  //     if (hoursController.text == null || hoursController.text.length == 0) {
  //       return;
  //     }

  //     int totalMinutes = int.parse(selectedMinuteValue) +
  //         (int.parse(hoursController.text) * 60);
  //   }

  //   creditRequest = totalMinutes / 60;
  //   //Just keeping 20 hours limit for previous versions of app whih did not had number of hours
  //   maxClaim =
  //       (widget.requestModel.numberOfHours ?? 20) / widget.requestModel.numberOfApprovals;

  //   if (creditRequest > maxClaim) {
  //     showDialogFoInfo(
  //       title: S.of(context).limit_exceeded,
  //       content:
  //           "${S.of(context).task_max_request_message} $maxClaim ${S.of(context).task_max_hours_of_credit}",
  //     );
  //     return;
  //     //show dialog
  //   } else if (creditRequest == 0) {
  //     showDialogFoInfo(
  //       title: S.of(context).enter_hours,
  //       content: S.of(context).validation_error_invalid_hours,
  //     );
  //     return;
  //   }

  //   Map results = await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (BuildContext context) {
  //         return ReviewFeedback(
  //           feedbackType: FeedbackType.FOR_REQUEST_CREATOR,
  //         );
  //       },
  //     ),
  //   );

  //   if (results != null && results.containsKey('selection')) {
  //     showProgressForCreditRetrieval();
  //     onActivityResult(results, SevaCore.of(context).loggedInUser);
  //   } else {}
  // }

  @override
  bool get wantKeepAlive => true;
}
