import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_plan_details.dart';
import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';

import '../bloc_provider.dart';

class ShowLimitBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProvider.of<UserDataBloc>(context);
    bool isAdmin =
        _userBloc.community.admins.contains(_userBloc.user.sevaUserID);

    return StreamBuilder<CommunityModel>(
      stream: _userBloc.comunityStream,
      builder: (context, AsyncSnapshot<CommunityModel> snapshot) {
        return Offstage(
          offstage: PaymentUtils.getFailedBannerVisibilityStatus(
            communityModel: _userBloc.community,
          ),
          child: Container(
            height: 20,
            width: double.infinity,
            color: Colors.red,
            alignment: Alignment.center,
            child: Center(
              child: Text(
                isAdmin
                    ? (_userBloc.community.payment['message'] != null
                        ? _userBloc.community.payment['message']
                        : S.of(context).payment_data_syncing)
                    : S.of(context).actions_not_allowed,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PaymentUtils {
  static bool getFailedBannerVisibilityStatus({
    CommunityModel communityModel,
  }) {
    if (!communityModel.payment['payment_success']) {
      if (communityModel.payment['status'] != null &&
          communityModel.payment['status'] ==
              SevaPaymentStatusCodes.PROCESSING_PLAN_UPDATE)
        return true;
      else
        return false;
    } else
      return true;
  }

  static bool isFailedOrProcessingPlanUpdate({
    CommunityModel communityModel,
  }) {
    if (communityModel.payment['status'] != null &&
        communityModel.payment['status'] ==
            SevaPaymentStatusCodes.PROCESSING_PLAN_UPDATE)
      return true;
    else
      return false;
  }
}

class SevaPaymentStatusCodes {
  static int PROCESSING_PLAN_UPDATE = 201;
}

class TransactionLimitCheck extends StatelessWidget {
  final Widget child;
  final bool isSoftDeleteRequested;

  const TransactionLimitCheck({
    Key key,
    this.child,
    @required this.isSoftDeleteRequested,
  })  : assert(isSoftDeleteRequested != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProvider.of<UserDataBloc>(context);
    return StreamBuilder(
      stream: _userBloc.comunityStream,
      builder: (context, AsyncSnapshot<CommunityModel> snapshot) {
        bool isAdmin =
            _userBloc.community.admins.contains(_userBloc.user.sevaUserID);
        bool isBillingFailed =
            !(_userBloc.community.payment['payment_success'] ?? false);

        bool exaustedLimit = getTransactionStatus(
          communityModel: _userBloc.community,
        );
        return GestureDetector(
          onTap: () {
            _showDialog(
              context,
              isAdmin,
              _userBloc.user,
              isBillingFailed,
              _userBloc.community.private,
              isBillingFailed
                  ? PaymentUtils.isFailedOrProcessingPlanUpdate(
                      communityModel: _userBloc.community,
                    )
                  : false,
              _userBloc.community.payment['planId'],
              exaustedLimit,
            );
          },
          child: AbsorbPointer(
            absorbing:
                isBillingFailed || isSoftDeleteRequested || exaustedLimit,
            child: child,
          ),
        );
      },
    );
  }

  void _showDialog(
    context,
    bool isAdmin,
    UserModel user,
    bool isBillingFailed,
    bool isPrivate,
    bool isUpdatingPlan,
    String activePlanId,
    bool exaustedLimit,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              Text(
                getMessage(
                  context: context,
                  isAdmin: isAdmin,
                  isSoftDeleteRequested: isSoftDeleteRequested,
                  isBillingFailed: isBillingFailed,
                  isUpdatingPlan: isUpdatingPlan,
                  exaustedLimit: exaustedLimit,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Offstage(
                offstage:
                    !isAdmin || (isSoftDeleteRequested && !isBillingFailed),
                child: FlatButton(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    S.of(context).configure_billing,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(_context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BillingPlanDetails(
                          activePlanId: activePlanId,
                          autoImplyLeading: true,
                          user: user,
                          isPlanActive: false,
                          isPrivateTimebank: isPrivate,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              FlatButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  S.of(context).close,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(_context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

bool getTransactionStatus({
  CommunityModel communityModel,
}) {
  int activeCount = 0;
  if (communityModel.payment['planId'] ==
          SevaBillingPlans.NEIGHBOUR_HOOD_PLAN &&
      communityModel.billingQuota != null) {
    List<String> neighbourhoodPlanBillableTransactions = List.castFrom(
        SevaPlansBillingConfig
            .billingPlans[SevaBillingPlans.NEIGHBOUR_HOOD_PLAN]['action']);

    neighbourhoodPlanBillableTransactions.forEach((billableItem) {
      if (communityModel.billingQuota.containsKey(billableItem)) {
        activeCount += communityModel.billingQuota[billableItem];
      }
    });
    return activeCount >= SevaPlansBillingConfig.NEIGHBOURHOOD_LIMIT;
  } else {
    return false;
  }
}

class SevaPlansBillingConfig {
  static final NEIGHBOURHOOD_LIMIT = 15;
  static Map<String, dynamic> billingPlans = {
    "neighbourhood_plan": {
      "initial_transactions_amount": 15,
      "initial_transactions_qty": 50,
      "pro_data_bill_amount": '0.05',
      'action': [
        // "quota_TypeJoinTimebank",
        "quota_TypeRequestApply",
        "quota_TypeRequestCreation",
        "quota_TypeRequestAccepted",
        "quota_TypeOfferCreated",
        "quota_TypeOfferAccepted"
      ],
    },
  };
}

String getMessage({
  BuildContext context,
  bool isAdmin,
  bool isBillingFailed,
  bool isSoftDeleteRequested,
  bool isUpdatingPlan,
  bool exaustedLimit,
}) {
  if (exaustedLimit) {
    return isAdmin
        ? "Please contact creator"
        : S.of(context).limit_badge_contact_admin;
  }

  if (isUpdatingPlan) {
    return isAdmin
        ? S.of(context).payment_still_processing
        : S.of(context).limit_badge_contact_admin;
  }

  if (isBillingFailed) {
    return isAdmin
        ? S.of(context).limit_badge_billing_failed
        : S.of(context).limit_badge_contact_admin;
  }
  if (isSoftDeleteRequested) {
    return isAdmin
        ? S.of(context).limit_badge_delete_in_progress
        : S.of(context).limit_badge_contact_admin;
  }

  return S.of(context).general_stream_error;
}
