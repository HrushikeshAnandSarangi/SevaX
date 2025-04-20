import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/core/error/failures.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/enums/plan_ids.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class PaymentRepository {
  static String _baseUrl =
      // 'http://192.168.1.4:5011/sevax-dev-project-for-sevax/us-central1/';
      // "https://proxy.sevaexchange.com/" +
      FlavorConfig.values.cloudFunctionBaseURL + '/';

  static Future<Either<Failure, bool>> subscribe({
    String? communityId,
    String? paymentMethodId,
    PlanIds? planId,
    bool? isPrivate,
    bool? isBundlePricingEnabled,
  }) async {
    try {
      logger.i(
          "hitting ${communityId} $paymentMethodId $planId $isPrivate $isBundlePricingEnabled");
      var result = await http.post(
        Uri.parse(_baseUrl + 'stripeCreateSubscription'),
        headers: {
          "content-type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        body: jsonEncode({
          "communityId": communityId,
          "paymentMethodId": paymentMethodId,
          "planId": planId?.label,
          "isPrivate": isPrivate,
          "isBundlePricingEnabled": isBundlePricingEnabled,
        }),
      );
      logger.i(result.body);
      if (result.statusCode == 200) {
        return right(true);
      } else {
        Map<String, dynamic> body = json.decode(result.body);
        return left(
          Failure(body.containsKey('message')
              ? body['message']
              : 'something went wrong'),
        );
      }
    } on Exception catch (e) {
      logger.e(e);
      return left(Failure(e.toString()));
    }
  }
}
