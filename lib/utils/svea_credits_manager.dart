import 'dart:convert';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'app_config.dart';

class SevaCreditLimitManager {
  static Future<double> getNegativeThresholdForCommunity(
    String communityId,
  ) async {
    var communityDoc = await CollectionRef.communities.doc(communityId).get();
    CommunityModel commModel =
        CommunityModel(communityDoc.data() as Map<String, dynamic>);
    return commModel.negativeCreditsThreshold;
  }

  static Future<double> getMemberBalancePerTimebank({
    required String userSevaId,
    required String communityId,
  }) async {
    double sevaCoinsBalance = 0.0;

    var snapTransactions = await CollectionRef.transactions
        .where("communityId", isEqualTo: communityId)
        .where("isApproved", isEqualTo: true)
        .where('transactionbetween', arrayContains: userSevaId)
        .orderBy("timestamp", descending: true)
        .get();

    TransactionModel transactionModel;
    for (var transactionDoc in snapTransactions.docs) {
      transactionModel = TransactionModel.fromMap(
          transactionDoc.data() as Map<String, dynamic>);
      final credits = transactionModel.credits ?? 0;
      if (transactionModel.from == userSevaId) {
        //lost credits
        sevaCoinsBalance -= credits.abs();
      } else {
        //gained credits
        sevaCoinsBalance += credits.abs();
      }
    }

    return sevaCoinsBalance;
  }

  static Future<bool> hasSufficientCreditsIncludingRecurring({
    required String userId,
    required double credits,
    required int recurrences,
    required bool isRecurring,
  }) async {
    var sevaCoinsBalance = await getMemberBalance(userId);
    var lowerLimit = 50.0;
    try {
      lowerLimit = (json.decode(
              AppConfig.remoteConfig!.getString('user_minimum_balance')) as num)
          .toDouble();
    } on Exception {
      //  FirebaseCrashlytics.instance.log(error.toString());
    }
    var maxAvailableBalance = sevaCoinsBalance + lowerLimit;
    var creditsNew = isRecurring ? credits * recurrences : credits;

    return maxAvailableBalance - (creditsNew) >= 0;
  }

  static Future<double> getMemberBalance(String userId) async {
    double sevaCoins = 0;
    var userModel = await FirestoreManager.getUserForIdFuture(
      sevaUserId: userId,
    );

    sevaCoins = AppConfig.isTestCommunity
        ? (userModel.sandboxCurrentBalance ?? 0.0)
        : (userModel.currentBalance ?? 0.0);
    return double.parse(sevaCoins.toStringAsFixed(2));
  }

  static Future<CreditResult> hasSufficientCredits({
    required String email,
    required String userId,
    required double credits,
    required String communityId,
  }) async {
    if (AppConfig.isTestCommunity) {
      return CreditResult(
        hasSuffiientCredits: true,
      );
    }

    var currentGlobalBalance = await getCurrentBalance(email: email);
    if (currentGlobalBalance >= credits) {
      return CreditResult(
        hasSuffiientCredits: true,
      );
    } else {
      var associatedBalanceWithinThisCommunity =
          await getMemberBalancePerTimebank(
        userSevaId: userId,
        communityId: communityId,
      );

      var communityThreshold =
          await getNegativeThresholdForCommunity(communityId);

      if (associatedBalanceWithinThisCommunity > communityThreshold) {
        var actualCredits = currentGlobalBalance > 0
            ? currentGlobalBalance - associatedBalanceWithinThisCommunity
            : 0;

        var maxCredit =
            (communityThreshold.abs() + associatedBalanceWithinThisCommunity);

        var canCreate = actualCredits + maxCredit >= credits;

        if (!canCreate) {
          return CreditResult(
            hasSuffiientCredits: false,
            credits: (credits - (actualCredits + maxCredit)),
          );
        }

        return CreditResult(
          hasSuffiientCredits: canCreate,
        );
      } else {
        return CreditResult(
          hasSuffiientCredits: false,
          credits: credits,
        );
      }
    }
  }

  static Future<double> checkCreditsNeeded({
    required String email,
    required String userId,
    required double credits,
    required String communityId,
  }) async {
    var associatedBalanceWithinThisCommunity =
        await getMemberBalancePerTimebank(
      userSevaId: userId,
      communityId: communityId,
    );
    var communityThreshold =
        await getNegativeThresholdForCommunity(communityId);

    var creditsNeeded = (credits -
        (associatedBalanceWithinThisCommunity + communityThreshold.abs()));

    return creditsNeeded;
  }

  static Future<double> getCurrentBalance({required String email}) {
    double FALLBACK_BALANCE = 0.0;
    return FirestoreManager.getUserForEmail(emailAddress: email)
        .then((value) => AppConfig.isTestCommunity
            ? (value.sandboxCurrentBalance ?? 0.0)
            : (value.currentBalance ?? 0.0))
        .catchError((onError) => FALLBACK_BALANCE);
  }
}

class CreditResult {
  final bool hasSuffiientCredits;
  final double credits;

  CreditResult({this.credits = 0, this.hasSuffiientCredits = true});
}
