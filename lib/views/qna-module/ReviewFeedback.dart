import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sevaexchange/views/qna-module/FeedbackConstants.dart';

class ReviewFeedback extends StatefulWidget {
  final bool forVolunteer;
  bool _validate = false;

  ReviewFeedback.forVolunteer({this.forVolunteer});
  @override
  State<StatefulWidget> createState() =>
      ReviewFeedbackState(forVolunteer: forVolunteer);
}

class ReviewFeedbackState extends State<ReviewFeedback> {
  var forVolunteer;
  ReviewFeedbackState({this.forVolunteer});

  var toolbarTitle = "Review";
  bool _validate = false;

  var questionIndex = 0;
  var totalScore = 0;
  TextEditingController myCommentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(toolbarTitle),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => {
                //  Navigator.popUntil(
                //     context, ModalRoute.withName(Navigator.defaultRouteName))

                Navigator.of(context).pop()
              },
            )),
        body: questionIndex <
                (forVolunteer
                    ? FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER.length
                    : FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN.length)
            ? getFeebackQuestions()
            : getTextFeedback(context),
      ),
    );
  }

  List<Map<String, Object>> getQuestions() => forVolunteer
      ? FeedbackConstants.FEEDBACK_QUESTIONS_FOR_VOLUNTEER
      : FeedbackConstants.FEEDBACK_QUESTIONS_FOR_ADMIN;

  Widget getFeebackQuestions() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10, bottom: 10, top: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            getQuestions()[questionIndex][FeedbackConstants.FEEDBACK_TITLE],
            style: TextStyle(fontSize: 19),
          ),
        ),
        ...(getQuestions()[questionIndex][FeedbackConstants.ANSWERS] as List)
            .map((answerModel) {
          return Container(
            margin: EdgeInsets.all(10),
            width: double.infinity,
            child: RaisedButton(
              child: Text(
                answerModel[FeedbackConstants.ANSWER_TEXT],
                style: TextStyle(fontWeight: FontWeight.bold),
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
      print("Quiz score $totalScore");
    });
  }

  void finishState(BuildContext context) {
    Navigator.of(context).pop({
      "selection": getRating(totalScore).toStringAsFixed(1),
      'didComment': myCommentsController.text.length > 0,
      'comment': myCommentsController.text
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: myCommentsController,
                  style: TextStyle(fontSize: 18.0, color: Colors.black87),
                  decoration: InputDecoration(
                    errorText: _validate ? 'Field can\'t be left blank' : null,
                    hintText:
                        'Take a minute to reflect on the experience and share a quick review.',
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
                    child: Text("Submit"),
                    onPressed: () {
                      setState(() {
                        myCommentsController.text.isEmpty
                            ? _validate = true
                            : _validate = false;
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
        ));
  }
}
