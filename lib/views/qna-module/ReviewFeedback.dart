import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/qna-module/FeedbackConstants.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:smooth_star_rating/smooth_star_rating.dart';

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

  bool _validate = false;

  num questionIndex = 0;
  num totalScore = 0;
  TextEditingController myCommentsController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  final _debouncerIng = Debouncer(milliseconds: 1500);
  bool isLoading = false;
  var ratings = {};
  constructor() {
    var temp = getQuestions(widget.feedbackType).length;
    for (var i=0; i< temp; i++) {
      ratings[i] = 0;
    }
    setState(() {
      ratings = ratings;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            AppLocalizations.of(context)
                .translate('review_feedback', 'review_toolbar_title'),
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
    var widgettype;
    if (widget.feedbackType == FeedbackType.FOR_REQUEST_VOLUNTEER) {
      widgettype = StarRating();
    } else {
      widgettype = getQuestionsWidget(widget, questionIndex);
    }
    return this.isLoading ? Center(child: CircularProgressIndicator()): Column(
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
        widgettype
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
    return (getQuestions(widget.feedbackType)[questionIndex]
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
    }).toList();
  }
  void finishState(BuildContext context) {
    Navigator.of(context).pop({
      "ratings": ratings,
      "selection": getRating(totalScore, widget.feedbackType == FeedbackType.FOR_REQUEST_VOLUNTEER ? 20: 15).toStringAsFixed(1),
      'didComment': myCommentsController.text.length > 0,
      'comment': myCommentsController.text
    });
  }

  double getRating(num totalScore, totalscoredenominator) {
    return 5 * (totalScore / totalscoredenominator);
  }

  Widget StarRating() {
    return SmoothStarRating(
        allowHalfRating: true,
        onRated: (v) {
          this.ratings[this.questionIndex] = v;
          setState(() {
            ratings = ratings;
          });
          _debouncerIng.run(() =>  {
            setState(() {
              isLoading = true;
            }),
            _debouncer.run(() =>  {
              makeSelection(v),
            })
          });
        },
        starCount: 5,
        rating: this.ratings[this.questionIndex] != null ? this.ratings[this.questionIndex]: 0,
        size: 40.0,
        filledIconData: Icons.star,
        halfFilledIconData: Icons.star_half,
        color: Colors.yellow,
        borderColor: Colors.yellow,
        spacing:0.0
    );
  }

  Widget getTextFeedback(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: myCommentsController,
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                decoration: InputDecoration(
                  errorText: _validate
                      ? AppLocalizations.of(context)
                          .translate('review_feedback', 'cant_leave_blank')
                      : null,
                  hintStyle: TextStyle(fontSize: 14),
                  // hintText:'Take a moment to reflect on your experience and share your appreciation by writing a short review.',
                  hintText: AppLocalizations.of(context)
                      .translate('review_feedback', 'take_a_moment'),
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
                    AppLocalizations.of(context)
                        .translate('review_feedback', 'review_submit'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      if ((FlavorConfig.appFlavor == Flavor.APP ||
                          FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
                        myCommentsController.text.isEmpty
                            ? _validate = true
                            : _validate = false;
                      }
                    });

                    if (!_validate) {
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
class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({ this.milliseconds });

  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
