class FeedbackConstants {
  static const FEEDBACK_TITLE = "feedbackTitle";
  static const ANSWERS = "answers";
  static const ANSWER_TEXT = "text";
  static const SCORE = "score";

  static const FEEDBACK_QUESTIONS_FOR_ADMIN = const [
    {
      FEEDBACK_TITLE: "How would you rate your experience in this cause?",
      ANSWERS: [
        {ANSWER_TEXT: "Excellent", SCORE: 5},
        {ANSWER_TEXT: "Very Good", SCORE: 4},
        {ANSWER_TEXT: "Good", SCORE: 3},
        {ANSWER_TEXT: "Fair", SCORE: 2},
        {ANSWER_TEXT: "Satsfactory.", SCORE: 1},
      ]
    },
    {
      FEEDBACK_TITLE: "Did you experience any diffculty in doing the task?",
      ANSWERS: [
        {ANSWER_TEXT: "No i really liked it", SCORE: 5},
        {ANSWER_TEXT: "Awesome! Loved it.", SCORE: 4},
        {ANSWER_TEXT: "Volunteer manager was rude", SCORE: 3},
        {ANSWER_TEXT: "Lack of organisation", SCORE: 2}
      ]
    },
    {
      FEEDBACK_TITLE: "Would you like to contribute more to this cause?",
      ANSWERS: [
        {"text": "Yes i would.", SCORE: 5},
        {"text": "May be, Not sure", SCORE: 4},
        {"text": "No i can't", SCORE: 3},
      ]
    }
  ];

  static const FEEDBACK_QUESTIONS_FOR_VOLUNTEER = const [
    {
      FEEDBACK_TITLE: "How would you rate your experience?",
      ANSWERS: [
        {ANSWER_TEXT: "Excellent", SCORE: 5},
        {ANSWER_TEXT: "Very Good", SCORE: 4},
        {ANSWER_TEXT: "Good", SCORE: 3},
        {ANSWER_TEXT: "Fair", SCORE: 2},
        {ANSWER_TEXT: "Satsfactory.", SCORE: 1},
      ]
    },
    {
      FEEDBACK_TITLE: "Was the volunteer on time?",
      ANSWERS: [
        {ANSWER_TEXT: "Yes he was", SCORE: 5},
        {ANSWER_TEXT: "He was a bit late", SCORE: 4},
        {ANSWER_TEXT: "He was too late", SCORE: 3},
        {ANSWER_TEXT: "He didn't show up", SCORE: 2}
      ]
    },
    {
      FEEDBACK_TITLE:
          "Would you like to consider this profile for future?",
      "answers": [
        {ANSWER_TEXT: "Yes i would", SCORE: 5},
        {ANSWER_TEXT: "May be, Not sure", SCORE: 4},
        {ANSWER_TEXT: "No i wont.", SCORE: 3},
      ]
    }
  ];
}
