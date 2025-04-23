import 'dart:async';
import 'package:universal_io/io.dart' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:doseform/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/device_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/qna-module/FeedbackConstants.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

enum FeedbackType {
  FOR_REQUEST_VOLUNTEER,
  FOR_REQUEST_CREATOR,
  FOR_ONE_TO_MANY_OFFER,
  FOR_BORROW_REQUEST_LENDER,
  FOR_BORROW_REQUEST_BORROWER,
  FOR_ONE_TO_MANY_REQUEST_ATTENDEE,
  FEEDBACK_FOR_BORROWER_FROM_LENDER,
  FEEDBACK_FOR_LENDER_FROM_BORROWER,
}

class ReviewFeedback extends StatefulWidget {
  // final bool forVolunteer;
  final FeedbackType? feedbackType;
  // final RequestModel requestModel;

  ReviewFeedback({
    this.feedbackType,
  });
  @override
  State<StatefulWidget> createState() => ReviewFeedbackState();
}

class ReviewFeedbackState extends State<ReviewFeedback> {
  // var forVolunteer;
  // ReviewFeedbackState({this.forVolunteer});
  final _formKey = GlobalKey<DoseFormState>();

  bool _validate = false;
  bool _profane = false;

  num questionIndex = 0;
  num totalScore = 0;
  TextEditingController myCommentsController = TextEditingController();
  FocusNode commentsFocusNode = FocusNode();
  final _debouncer = Debouncer(milliseconds: 500);
  final _debouncerIng = Debouncer(milliseconds: 1500);
  bool isLoading = false;
  var ratings = Map<String, dynamic>();
  // constructor() {
  //   var temp = getQuestions(widget.feedbackType).length;
  //   for (var i = 0; i < temp; i++) {
  //     ratings[i.toString()] = 0;
  //   }
  //   setState(() {
  //     ratings = ratings;
  //   });
  // }

  DeviceModel deviceModel =
      DeviceModel(osName: '', platform: '', version: '', model: '');
  final profanityDetector = ProfanityDetector();

  @override
  void initState() {
    super.initState();

    getDeviceDetails();
  }

  void getDeviceDetails() async {
    if (io.Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      deviceModel.platform = 'Android';
      deviceModel.osName = androidInfo.brand;
      deviceModel.model = androidInfo.model;
      deviceModel.version = androidInfo.version.release;
    }

    if (io.Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceModel.platform = 'IOS';
      deviceModel.version = iosInfo.systemVersion;
      deviceModel.model = iosInfo.utsname.machine;
      deviceModel.osName = iosInfo.systemName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).review,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => {
            //  Navigator.popUntil(
            //     context, ModalRoute.withName(Navigator.defaultRouteName))

            Navigator.of(context).pop()
          },
        ),
      ),
      body: questionIndex < getQuestions(widget.feedbackType!).length
          ? getFeebackQuestions()
          : getTextFeedback(context),
    );
  }

  List<Map<String, Object>> getQuestions(FeedbackType type) {
    String languageCode = AppConfig.prefs!.getString('language_code')!;

    switch (type) {
      case FeedbackType.FOR_REQUEST_CREATOR:
        return getFeedbackQuestionsForAdmin(languageCode);

      case FeedbackType.FOR_REQUEST_VOLUNTEER:
        return getFeedbackQUestionsForVolunteers(languageCode);

      case FeedbackType.FOR_ONE_TO_MANY_OFFER:
        return getFeedbackQuestionForOneToManyOffer(languageCode);

      case FeedbackType.FOR_BORROW_REQUEST_LENDER:
        return getFeedbackQuestionsForLender(languageCode);

      case FeedbackType.FOR_BORROW_REQUEST_BORROWER:
        return getFeedbackQuestionsForBorrower(languageCode);

      case FeedbackType.FEEDBACK_FOR_BORROWER_FROM_LENDER:
        return getFeedbackQuestionsForLender(languageCode);

      case FeedbackType.FEEDBACK_FOR_LENDER_FROM_BORROWER:
        return getFeedbackQuestionsForBorrower(languageCode);

      case FeedbackType.FOR_ONE_TO_MANY_REQUEST_ATTENDEE:
        return getFeedbackQuestionForOneToManyRequestAttendee(languageCode);

      default:
        throw "FEEDBACK TYPE NOT DEFINED";
    }
  }

  List<Map<String, Object>> getFeedbackQuestionsForLender(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_LENDER_EN;

      // case 'sn':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_SN;
      // case 'af':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_AF;
      // case 'sw':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_SW;

      // case 'fr':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_FR;

      // case 'pt':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_PT;

      // case 'es':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_ES;

      // case 'zh':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_ZH_CN;

      default:
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_EN;
    }
  }

  List<Map<String, Object>> getFeedbackQuestionsForBorrower(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_BORROWER_EN;

      // case 'sn':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_SN;
      // case 'af':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_AF;
      // case 'sw':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_SW;

      // case 'fr':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_FR;

      // case 'pt':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_PT;

      // case 'es':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_ES;

      // case 'zh':
      //   return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_ZH_CN;

      default:
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_EN;
    }
  }

  List<Map<String, Object>> getFeedbackQuestionsForAdmin(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_EN;

      case 'sn':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_SN;
      case 'af':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_AF;
      case 'sw':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_SW;

      case 'fr':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_FR;

      case 'pt':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_PT;

      case 'es':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_ES;

      case 'zh':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_ZH_CN;

      default:
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_EN;
    }
  }

  List<Map<String, Object>> getFeedbackQUestionsForVolunteers(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_EN;
      case 'af':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_AF;
      case 'sn':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_SN;
      case 'sw':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_SW;
      case 'fr':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_FR;

      case 'pt':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_PT;

      case 'es':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_ES;

      case 'zh':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_CN;

      default:
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER_EN;
    }
  }

  List<Map<String, Object>> getFeedbackQuestionForOneToManyOffer(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_EN;
      case 'af':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_AF;
      case 'sn':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_SN;

      case 'sw':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_SW;

      case 'fr':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_FR;

      case 'pt':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_PT;

      case 'es':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_ES;

      case 'zh':
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_CN;

      default:
        return FeedbackConstants.FEEDBACK_QUESTION_FOR_ONE_TO_MANY_OFFER_EN;
    }
  }

  List<Map<String, Object>> getFeedbackQuestionForOneToManyRequestAttendee(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_EN;
      case 'af':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_AF;
      case 'sn':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_SN;

      case 'sw':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_SW;

      case 'fr':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_FR;

      case 'pt':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_PT;

      case 'es':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_ES;

      case 'zh':
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_CN;

      default:
        return FeedbackConstants
            .FEEDBACK_QUESTION_FOR_ONE_TO_MANY_REQUEST_ATTENDEE_EN;
    }
  }

  Widget getFeebackQuestions() {
    Widget widgettype;
    if (widget.feedbackType == FeedbackType.FOR_REQUEST_VOLUNTEER ||
        widget.feedbackType == FeedbackType.FOR_BORROW_REQUEST_BORROWER ||
        widget.feedbackType == FeedbackType.FOR_BORROW_REQUEST_LENDER ||
        widget.feedbackType == FeedbackType.FEEDBACK_FOR_BORROWER_FROM_LENDER ||
        widget.feedbackType == FeedbackType.FEEDBACK_FOR_LENDER_FROM_BORROWER ||
        widget.feedbackType == FeedbackType.FOR_ONE_TO_MANY_REQUEST_ATTENDEE) {
      widgettype = StarRating();
    } else {
      widgettype = getQuestionsWidget(widget, questionIndex);
    }
    return this.isLoading
        ? Center(child: LoadingIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 0),
                child: Text((questionIndex + 1).toString() +
                    ' / ${getQuestions(widget.feedbackType!).length}'),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                alignment: Alignment.center,
                child: Text(
                  getQuestions(widget.feedbackType!)[questionIndex.toInt()]
                      [FeedbackConstants.FEEDBACK_TITLE] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(child: widgettype),
            ],
          );
  }

  void makeSelection(num score) {
    setState(() {
      questionIndex++;
      totalScore = totalScore += score;
      isLoading = false;
    });
  }

  getQuestionsWidget(widget, questionIndex) {
    List<Container> tempWidget =
        (getQuestions(widget.feedbackType)[questionIndex]
                [FeedbackConstants.ANSWERS] as List)
            .map((answerModel) {
      return Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        child: CustomElevatedButton(
          shape: StadiumBorder(),
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.all(12),
          elevation: 2.0,
          textColor: Colors.white,
          child: Text(
            answerModel[FeedbackConstants.ANSWER_TEXT],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: () {
            makeSelection(answerModel[FeedbackConstants.SCORE]);
          },
        ),
      );
    }).toList();
    return ListView(
      children: tempWidget,
    );
  }

  void finishState(BuildContext context) {
    Navigator.of(context).pop({
      "ratings": ratings,
      "selection": getRating(
              totalScore,
              (widget.feedbackType == FeedbackType.FOR_REQUEST_VOLUNTEER ||
                      widget.feedbackType ==
                          FeedbackType.FOR_BORROW_REQUEST_BORROWER)
                  ? 20
                  : 15)
          .toStringAsFixed(1),
      'didComment': myCommentsController.text.length > 0,
      'comment': myCommentsController.text,
      'device_info': deviceModel.toMap(),
    });
  }

  double getRating(num totalScore, totalscoredenominator) {
    return 5 * (totalScore / totalscoredenominator);
  }

  Widget StarRating() {
    return RatingBar.builder(
        allowHalfRating: true,
        onRatingUpdate: (v) {
          this.ratings[this.questionIndex.toString()] = v;
          setState(() {
            ratings = ratings;
          });
          _debouncerIng.run(() => {
                setState(() {
                  isLoading = true;
                }),
                _debouncer.run(() => {
                      makeSelection(v),
                    })
              });
        },
        itemCount: 5,
        initialRating: this.ratings[this.questionIndex.toString()] != null
            ? this.ratings[this.questionIndex.toString()]
            : 0,
        itemSize: 40.0,
        itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ));
  }

  Widget getTextFeedback(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: DoseForm(
          formKey: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DoseTextField(
                textCapitalization: TextCapitalization.sentences,
                controller: myCommentsController,
                focusNode: commentsFocusNode,
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {},
                decoration: InputDecoration(
                  errorMaxLines: 2,

                  errorText: _validate
                      ? S.of(context).validation_error_required_fields
                      : _profane
                          ? S.of(context).profanity_text_alert
                          : null,
                  hintStyle: TextStyle(fontSize: 14),
                  // hintText:'Take a moment to reflect on your experience and share your appreciation by writing a short review.',
                  hintText: S.of(context).review_feedback_message,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red, //this has no effect
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                // enabled: true,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
              CustomElevatedButton(
                shape: StadiumBorder(),
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(12),
                elevation: 2.0,
                textColor: Colors.white,
                child: Text(
                  S.of(context).submit,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    if ((FlavorConfig.appFlavor == Flavor.APP ||
                        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
                      myCommentsController.text.isEmpty
                          ? _validate = true
                          : _validate = false;
                      if (profanityDetector
                          .isProfaneString(myCommentsController.text)) {
                        setState(() {
                          _profane = true;
                        });
                      } else {
                        setState(() {
                          _profane = false;
                        });
                      }
                    }
                  });

                  if (!_validate && !_profane) {
                    finishState(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Debouncer {
  final int? milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}
