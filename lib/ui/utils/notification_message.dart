// One to many offer notifications
// --DEBIT_FROM_OFFER,
// CREDIT_FROM_OFFER_ON_HOLD,//timebank notification
// CREDIT_FROM_OFFER_APPROVED,//timebank notification
// --CREDIT_FROM_OFFER,//user notification
// DEBIT_FULFILMENT_FROM_TIMEBANK,//timebank notification
// --NEW_MEMBER_SIGNUP_OFFER,//user notification
// --OFFER_FULFILMENT_ACHIEVED,// user notification
// --OFFER_SUBSCRIPTION_COMPLETED,//user ///successfully signed up
// --FEEDBACK_FROM_SIGNUP_MEMBER,//feedback user

///Replace the string accordingly [*n -> seva credits] [*class -> class name] [*name -> name]
class UserNotificationMessage {
  static const String CREDIT_FROM_OFFER =
      "You have been credited *n seva credits for the *class that you hosted";
  static const String DEBIT_FROM_OFFER =
      "*n seva credits have been debited from your account";
  static const String NEW_MEMBER_SIGNUP_OFFER =
      "*name has signed up for you class \"*class\"";
  static const String OFFER_SUBSCRIPTION_COMPLETED =
      "You have successfully signed up for the *class";
  static const String OFFER_FULFILMENT_ACHIEVED =
      "You have recieved *n seva credits for the *class that you recently hosted";
  static const String FEEDBACK_FROM_SIGNUP_MEMBER =
      "Please provide feedback for the *class that you recently attended";
}

class TimebankNotificationMessage {
  static const String DEBIT_FULFILMENT_FROM_TIMEBANK =
      "*n seva credits have been sent to *name from the credits recieved for *class ";
  static const String CREDIT_FROM_OFFER_APPROVED =
      "Recieved *n credits from the the offer *class";
}
