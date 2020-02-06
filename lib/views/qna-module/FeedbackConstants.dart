class FeedbackConstants {
  static const FEEDBACK_TITLE = "feedbackTitle";
  static const ANSWERS = "answers";
  static const ANSWER_TEXT = "text";
  static const SCORE = "score";

  static const FEEDBACK_QUESTIONS_FOR_ADMIN = const [
    {
      FEEDBACK_TITLE: "How would you rate your experience?",
      ANSWERS: [
        {ANSWER_TEXT: "Excellent", SCORE: 5},
        {ANSWER_TEXT: "Good", SCORE: 4},
        {ANSWER_TEXT: "Okay", SCORE: 3},
        {ANSWER_TEXT: "Not so good", SCORE: 2},
        {ANSWER_TEXT: "Terrible", SCORE: 1},
      ]
    },
    {
      FEEDBACK_TITLE:
          "Did you experience any diffculty in completing the task?",
      ANSWERS: [
        {ANSWER_TEXT: "No difficulty", SCORE: 5},
        {ANSWER_TEXT: "Only slightly", SCORE: 4},
        {ANSWER_TEXT: "Yes, I had some difficulty", SCORE: 3},
      ]
    },
    {
      FEEDBACK_TITLE: "How likely are you to volunteer again for this cause?",
      ANSWERS: [
        {"text": "Yes, I would", SCORE: 5},
        {"text": "Maybe", SCORE: 4},
        {"text": "No, I would not", SCORE: 3},
      ]
    }
  ];

  static const FEEDBACK_QUESTIONS_FOR_VOLUNTEER = const [
    {
      FEEDBACK_TITLE: "How would you rate your experience with this volunteer?",
      ANSWERS: [
        {ANSWER_TEXT: "Excellent", SCORE: 5},
        {ANSWER_TEXT: "Good", SCORE: 4},
        {ANSWER_TEXT: "Okay", SCORE: 3},
        {ANSWER_TEXT: "Not so good", SCORE: 2},
        {ANSWER_TEXT: "Terrible", SCORE: 1},
      ]
    },
    {
      FEEDBACK_TITLE: "Did the volunteer show up on time?",
      ANSWERS: [
        {ANSWER_TEXT: "On time", SCORE: 3},
        {ANSWER_TEXT: "A bit late", SCORE: 4},
        {ANSWER_TEXT: "Kept me waiting", SCORE: 3},
        {ANSWER_TEXT: "Didn't show up", SCORE: 2}
      ]
    },
    {
      FEEDBACK_TITLE:
          "Would you like to recommend working with this volunteer again?",
      "answers": [
        {ANSWER_TEXT: "Yes, I would", SCORE: 3},
        {ANSWER_TEXT: "No, i would not", SCORE: 2},
      ]
    },
    {
      FEEDBACK_TITLE:
          "How skillful was this volunteer for this particular service?",
      "answers": [
        {ANSWER_TEXT: "Highly skilled", SCORE: 3},
        {ANSWER_TEXT: "Average", SCORE: 3},
        {ANSWER_TEXT: "Not skilled at all", SCORE: 1},
      ]
    }
  ];
}
