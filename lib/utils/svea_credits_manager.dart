import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import 'app_config.dart';

class SevaCreditLimitManager {
  static Future<double> getNegativeThresholdForCommunity(
    communityId,
  ) async {
    var communityDoc = await CollectionRef.communities.doc(communityId).get();
    CommunityModel commModel = CommunityModel(communityDoc.data());
    return commModel.negativeCreditsThreshold ?? 50;
  }

  static Future<double> getMemberBalancePerTimebank({
    String userSevaId,
    String communityId,
  }) async {
    double sevaCoinsBalance = 0.0;

    var snapTransactions = await CollectionRef.transactions
        .where("communityId", isEqualTo: communityId)
        .where("isApproved", isEqualTo: true)
        .where('transactionbetween', arrayContains: userSevaId)
        .orderBy("timestamp", descending: true)
        .get();

    TransactionModel transactionModel;
    snapTransactions.docs.forEach((transactionDoc) {
      transactionModel = TransactionModel.fromMap(transactionDoc.data());
      if (transactionModel.from == userSevaId) {
        //lost credits
        sevaCoinsBalance -= transactionModel.credits > 0
            ? transactionModel.credits
            : transactionModel.credits.abs();
      } else {
        //gained credits
        sevaCoinsBalance += transactionModel.credits > 0
            ? transactionModel.credits
            : transactionModel.credits.abs();
      }
    });

    return sevaCoinsBalance;
  }

  static Future<bool> hasSufficientCreditsIncludingRecurring({
    String userId,
    double credits,
    int recurrences,
    bool isRecurring,
  }) async {
    var sevaCoinsBalance = await getMemberBalance(userId);
    log("on mode recurrence count isss $recurrences");
    var lowerLimit = 50;
    try {
      lowerLimit =
          json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));
    } on Exception {
      //  FirebaseCrashlytics.instance.log(error.toString());
    }
    var maxAvailableBalance = (sevaCoinsBalance + lowerLimit ?? 50);
    var creditsNew = isRecurring ? credits * recurrences : credits;

    return maxAvailableBalance - (creditsNew) >= 0;
  }

  static Future<double> getMemberBalance(userId) async {
    double sevaCoins = 0;
    var userModel = await FirestoreManager.getUserForIdFuture(
      sevaUserId: userId,
    );

    sevaCoins = AppConfig.isTestCommunity
        ? userModel.sandboxCurrentBalance
        : userModel.currentBalance;
    return double.parse(sevaCoins.toStringAsFixed(2));
  }

  static Future<CreditResult> hasSufficientCredits({
    @required String email,
    @required String userId,
    @required double credits,
    @required String communityId,
  }) async {
    if (AppConfig.isTestCommunity) {
      return new CreditResult(
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
    @required String email,
    @required String userId,
    @required double credits,
    @required String communityId,
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

    log('credits:  ' + associatedBalanceWithinThisCommunity.toString());
    log('CAB:  ' + associatedBalanceWithinThisCommunity.toString());
    log('CT:  ' + communityThreshold.toString());
    log('cNeeded:  ' + creditsNeeded.toString());
    return creditsNeeded;
  }

  static Future<double> getCurrentBalance({String email}) {
    int FALLBACK_BALANCE = 0;
    return FirestoreManager.getUserForEmail(emailAddress: email)
        .then((value) => AppConfig.isTestCommunity
            ? value.sandboxCurrentBalance
            : value.currentBalance)
        .catchError((onError) => FALLBACK_BALANCE);
  }
}

class CreditResult {
  final bool hasSuffiientCredits;
  final double credits;

  CreditResult({this.credits = 0, this.hasSuffiientCredits = true});
}
