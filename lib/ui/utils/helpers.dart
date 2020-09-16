import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';

///[Function] clear all notification
///
///Pass list of all notifications that are allowed to be cleared
void clearAllNotification(List<NotificationsModel> notifications,
    List<NotificationType> allowedNotifications, String userEmail) {
  WriteBatch batch = Firestore.instance.batch();
  notifications.forEach((NotificationsModel notification) {
    if (allowedNotifications.contains(notification.type)) {
      batch.updateData(
          Firestore.instance
              .collection("users")
              .document(userEmail)
              .collection("notifications")
              .document(notification.id),
          {"isRead": true});
    }
  });
  batch.commit();
}

//Fetch location
Future<String> getLocation(GeoFirePoint location) async {
  String address = await LocationUtility().getFormattedAddress(
    location.latitude,
    location.longitude,
  );
  return address;
}

handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
    type, results, model, UserModel user) async {
  /* Here are the questions that should be asked (replacing the current ones)
    How likely are you to recommend this person / service to a friend, on a scale between 0-10 where 0 = Not at all Likely and 10 = Extremely Likely

    How satisfied are you with the person / service, on a scale between 0-10 where 0 = Not at all Satisfied and 10 = Extremely Satisfied

    How easy was it for you to get the job done, on a scale between 0-10 where 0 = Not at all Easy and 10 = Extremely Easy

    How satisfied are you with the ability of the person / service to get the job done, on a scale between 0-10 where 0 = Not at all Satisfied and 10 = Extremely Satisfied

    Please provide an appreciation review to the person / service about your experience

    Computing the “Trustworthiness” index - this is shown in 5 stars

    Take the sum of scores for Questions A and B, divide by total number of responses. This is computed and stored for each person on a daily basis (that is a cron job is run once a day for each person in each Timebank to compute this score - which is stored against that person as “Trustworthiness index”).
    Use this heuristic to arrive at the stars:
    Average score between 18 and 20                                                   - 5 stars
    Average score above 14 (¼ of a star for every point above 14)  - 4 stars
    So a score of 16 would mean 4.5 stars
    Average score above 10 (¼ of a star for every point above 10)  - 3 stars
    Average score above 6 (¼ of a star for every point above 6)       - 2 stars
    Average score above 2 (¼ of a star for every point above 2)       - 1 star

    Computing the “Reliability” index - shown in 5 stars
      Take the sum of scores for Questions C and D, divide by total number of responses. This is computed and stored for each person on a daily basis (that is a cron job is run once a day for each person in each Timebank to compute this score - which is stored against that person as “Reliability Index”).
    Use this heuristic to arrive at the stars:
    Average score between 18 and 20                                                   - 5 stars
    Average score above 14 (¼ of a star for every point above 14)  - 4 stars
    So a score of 16 would mean 4.5 stars
    Average score above 10 (¼ of a star for every point above 10)  - 3 stars
    Average score above 6 (¼ of a star for every point above 6)       - 2 stars
    Average score above 2 (¼ of a star for every point above 2)       - 1 star
    */
  ratingCal(total) {
    if (total <= 1) {
      return 1;
    } else if (total >= 9) {
      return 5;
    } else {
      var starat = ((total - 1) / 2) + 1;
      return starat;
    }
  }

  averageReview(totalreviews, currentreview, pastreview) {
    print(totalreviews);
    print(currentreview);
    print(pastreview);
    print((pastreview * totalreviews + currentreview) / (totalreviews + 1));
    return (pastreview * totalreviews + currentreview) / (totalreviews + 1);
  }

  if (type == FeedbackType.FOR_REQUEST_VOLUNTEER) {
    var temp = results['ratings'];
    print(temp);
    await Firestore.instance.collection('users').document(user.email).setData({
      'totalReviews': FieldValue.increment(1),
      'reliabilityscore': averageReview(user.totalReviews,
          ratingCal(temp['0'] + temp['1']), user.reliabilityscore),
      'trustworthinessscore': averageReview(user.totalReviews,
          ratingCal(temp['2'] + temp['3']), user.trustworthinessscore)
    }, merge: true);
  }
}
