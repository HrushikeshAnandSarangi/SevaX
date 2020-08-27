import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/device_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/qna-module/FeedbackConstants.dart';

enum FeedbackType {
  FOR_REQUEST_VOLUNTEER,
  FOR_REQUEST_CREATOR,
  FOR_ONE_TO_MANY_OFFER,
}

class ReviewFeedback extends StatefulWidget {
  // final bool forVolunteer;
  final FeedbackType feedbackType;

  ReviewFeedback({this.feedbackType});
  @override
  State<StatefulWidget> createState() => ReviewFeedbackState();
}

class ReviewFeedbackState extends State<ReviewFeedback> {
  // var forVolunteer;
  // ReviewFeedbackState({this.forVolunteer});
  final _formKey = GlobalKey<FormState>();

  bool _validate = false;
  bool _profane = false;

  var questionIndex = 0;
  var totalScore = 0;
  TextEditingController myCommentsController = TextEditingController();
  DeviceModel deviceModel = DeviceModel();
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getDeviceDetails();
  }

  void getDeviceDetails() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      deviceModel.platform = 'Android';
      deviceModel.osName = androidInfo.brand;
      deviceModel.model = androidInfo.model;
      deviceModel.version = androidInfo.version.release;
      // print('Android  info ${deviceModel}');
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceModel.platform = 'IOS';
      deviceModel.version = iosInfo.systemVersion;
      deviceModel.model = iosInfo.utsname.machine;
      deviceModel.osName = iosInfo.systemName;
      //  print('ios info $deviceModel  name ${iosInfo.name}');
      // iOS 13.1, iPhone 11 Pro Max iPhone
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: AppConfig.appName,
      home: Scaffold(
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
        body: questionIndex < getQuestions(widget.feedbackType).length
            ? getFeebackQuestions()
            : getTextFeedback(context),
      ),
    );
  }

  List<Map<String, Object>> getQuestions(FeedbackType type) {
    String languageCode = AppConfig.prefs.getString('language_code');

    switch (type) {
      case FeedbackType.FOR_REQUEST_CREATOR:
        return getFeedbackQuestionsForAdmin(languageCode);

      case FeedbackType.FOR_REQUEST_VOLUNTEER:
        return getFeedbackQUestionsForVolunteers(languageCode);

      case FeedbackType.FOR_ONE_TO_MANY_OFFER:
        return getFeedbackQuestionForOneToManyOffer(languageCode);

      default:
        throw "FEEDBACK TYPE NOT DEFINED";
    }
  }

  List<Map<String, Object>> getFeedbackQuestionsForAdmin(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN_EN;

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

  Widget getFeebackQuestions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10, bottom: 10, top: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            getQuestions(widget.feedbackType)[questionIndex]
                [FeedbackConstants.FEEDBACK_TITLE],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ),
        ...(getQuestions(widget.feedbackType)[questionIndex]
                [FeedbackConstants.ANSWERS] as List)
            .map((answerModel) {
          return Container(
            margin: EdgeInsets.all(10),
            width: double.infinity,
            child: RaisedButton(
              shape: StadiumBorder(),
              color: Color(0x0FF766FE0),
              child: Text(
                answerModel[FeedbackConstants.ANSWER_TEXT],
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () {
                makeSelection(answerModel[FeedbackConstants.SCORE]);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  void makeSelection(int score) {
    setState(() {
      questionIndex++;
      totalScore = totalScore += score;
    });
  }

  void finishState(BuildContext context) {
    Navigator.of(context).pop({
      "selection": getRating(totalScore).toStringAsFixed(1),
      'didComment': myCommentsController.text.length > 0,
      'comment': myCommentsController.text,
      'device_info': deviceModel.toMap(),
    });
  }

  double getRating(int totalScore) {
    return 5 * (totalScore / 15);
  }

  Widget getTextFeedback(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: myCommentsController,
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                autovalidate: autoValidateText,
                onChanged: (value) {
                  if (value.length > 1 && !autoValidateText) {
                    setState(() {
                      autoValidateText = true;
                    });
                  }
                  if (value.length <= 1 && autoValidateText) {
                    setState(() {
                      autoValidateText = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  errorMaxLines: 2,

                  errorText: _validate
                      ? S.of(context).validation_error_required_fields
                      : _profane ? S.of(context).profanity_text_alert : null,
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
                enabled: true,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  shape: StadiumBorder(),
                  color: Color(0x0FF766FE0),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
