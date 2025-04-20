import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';

import '../bloc_provider.dart';

// class ShowLimitBadge extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final _userBloc = BlocProvider.of<UserDataBloc>(context);
//     bool isAdmin =
//         _userBloc.community.admins.contains(_userBloc.user.sevaUserID);

//     return StreamBuilder<CommunityModel>(
//       stream: _userBloc.comunityStream,
//       builder: (context, AsyncSnapshot<CommunityModel> snapshot) {
//         return Offstage(
//           offstage: PaymentUtils.getFailedBannerVisibilityStatus(
//             communityModel: _userBloc.community,
//           ),
//           child: Container(
//             height: 20,
//             width: double.infinity,
//             color: Colors.red,
//             alignment: Alignment.center,
//             child: Center(
//               child: Text(
//                 isAdmin
//                     ? (_userBloc.community.payment['message'] != null
//                         ? _userBloc.community.payment['message']
//                         : S.of(context).payment_data_syncing)
//                     : S.of(context).actions_not_allowed,
//                 style: TextStyle(color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class PaymentUtils {
//   static bool getFailedBannerVisibilityStatus({
//     CommunityModel communityModel,
//   }) {
//     if (communityModel.payment == null ||
//         !communityModel.payment.containsKey('payment_success')) {
//       return true;
//     }

//     if (!communityModel.payment['payment_success'] ?? false) {
//       if (communityModel.payment['status'] != null &&
//           communityModel.payment['status'] ==
//               SevaPaymentStatusCodes.PROCESSING_PLAN_UPDATE)
//         return true;
//       else
//         return false;
//     } else
//       return true;
//   }

//   static bool isFailedOrProcessingPlanUpdate({
//     CommunityModel communityModel,
//   }) {
//     if (communityModel.payment['status'] != null &&
//         communityModel.payment['status'] ==
//             SevaPaymentStatusCodes.PROCESSING_PLAN_UPDATE)
//       return true;
//     else
//       return false;
//   }
// }

// class SevaPaymentStatusCodes {
//   static int PROCESSING_PLAN_UPDATE = 201;
// }

enum ViewerRole {
  CREATOR,
  ADMIN,
  MEMBER,
}

class TransactionLimitCheck extends StatelessWidget {
  final String timebankId;
  final Widget? child;
  final bool isSoftDeleteRequested;
  final ComingFrom comingFrom;

  TransactionLimitCheck({
    Key? key,
    this.child,
    required this.isSoftDeleteRequested,
    required this.comingFrom,
    required this.timebankId,
  });

  ViewerRole initViewerRole(UserDataBloc _userBloc) {
    if (_userBloc.community.created_by == _userBloc.user.sevaUserID) {
      return ViewerRole.CREATOR;
    }

    if (_userBloc.community.admins.contains(_userBloc.user.sevaUserID)) {
      return ViewerRole.ADMIN;
    }

    return ViewerRole.MEMBER;
  }

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProvider.of<UserDataBloc>(context);
    return StreamBuilder(
      stream: _userBloc!.comunityStream,
      builder: (context, AsyncSnapshot<CommunityModel> snapshot) {
        ViewerRole viewRole = initViewerRole(_userBloc);
        bool isBillingFailed = !(_userBloc.community.payment != null &&
            _userBloc.community.payment.containsKey('payment_success') &&
            (_userBloc.community.payment['payment_success'] ?? false));

        // bool exaustedLimit = getTransactionStatus(
        //   communityModel: _userBloc.community,
        // );
        return GestureDetector(
          onTap: () {
            _showDialog(
              context,
              viewRole,
              _userBloc.user,
              isBillingFailed,
              _userBloc.community.private,
              // isBillingFailed
              //     ? PaymentUtils.isFailedOrProcessingPlanUpdate(
              //         communityModel: _userBloc.community,
              //       )
              //     : false,
              // _userBloc.community.payment['planId'],
              // exaustedLimit,
              // _userBloc.community.billMe,
            );
          },
          child: AbsorbPointer(
            absorbing: isSoftDeleteRequested || isBillingFailed,
            // isBillingFailed || isSoftDeleteRequested || exaustedLimit,
            child: child,
          ),
        );
      },
    );
  }

  void _showDialog(
    context,
    ViewerRole viewRole,
    UserModel user,
    bool isBillingFailed,
    bool isPrivate,
    // bool isUpdatingPlan,
    // String activePlanId,
    // bool exaustedLimit,
    // bool isBillMe,
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
                  viewRole: viewRole,
                  isSoftDeleteRequested: isSoftDeleteRequested,
                  isBillingFailed: isBillingFailed,
                  // isUpdatingPlan: isUpdatingPlan,
                  // exaustedLimit: exaustedLimit,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 10),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
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

class SevaPlansBillingConfig {
  static Map<String, dynamic> plansLimit = {
    "neighbourhood_plan": 15,
    "tall_plan": 50,
    "community_plus_plan": 150,
    "grande_plan": 3000,
    "venti_plan": 5000
  };

  static Map<String, dynamic> billingPlans = {
    "neighbourhood_plan": {
      "initial_transactions_amount": 0,
      "initial_transactions_qty": 15,
      'action': [
//         "quota_TypeJoinTimebank",
        "quota_TypeRequestApply",
        "quota_TypeRequestCreation",
        "quota_TypeRequestAccepted",
        "quota_TypeOfferCreated",
        "quota_TypeOfferAccepted"
      ],
    },
    "tall_plan": {
      "initial_transactions_amount": 0,
      "initial_transactions_qty": 50,
      'action': [
        "quota_TypeJoinTimebank",
        "quota_TypeRequestApply",
        "quota_TypeRequestCreation",
        "quota_TypeRequestAccepted",
        "quota_TypeOfferCreated",
        "quota_TypeOfferAccepted"
      ],
    },
    "community_plus_plan": {
      "initial_transactions_amount": 0,
      "initial_transactions_qty": 150,
      'action': [
        "quota_TypeJoinTimebank",
        "quota_TypeRequestApply",
        "quota_TypeRequestCreation",
        "quota_TypeRequestAccepted",
        "quota_TypeOfferCreated",
        "quota_TypeOfferAccepted"
      ],
    },
    "grande_plan": {
      "initial_transactions_amount": 0,
      "initial_transactions_qty": 3000,
      'action': [
        "quota_TypeJoinTimebank",
        "quota_TypeRequestApply",
        "quota_TypeRequestCreation",
        "quota_TypeRequestAccepted",
        "quota_TypeOfferCreated",
        "quota_TypeOfferAccepted"
      ],
    },
    "venti_plan": {
      "initial_transactions_amount": 0,
      "initial_transactions_qty": 5000,
      'action': [
        "quota_TypeJoinTimebank",
        "quota_TypeRequestApply",
        "quota_TypeRequestCreation",
        "quota_TypeRequestAccepted",
        "quota_TypeOfferCreated",
        "quota_TypeOfferAccepted"
      ],
    }
  };
}

String getRoleAssociatedMessage({
  ViewerRole? viewRole,
  String? forCreator,
  String? forAdmin,
  String? forMember,
}) {
  switch (viewRole) {
    case ViewerRole.ADMIN:
      return forAdmin!;

    case ViewerRole.CREATOR:
      return forCreator!;

    case ViewerRole.MEMBER:
      return forMember!;

    default:
      return "";
  }
}

String getMessage({
  BuildContext? context,
  ViewerRole? viewRole,
  bool? isBillingFailed,
  bool? isSoftDeleteRequested,
  // bool isUpdatingPlan,
  // bool exaustedLimit,
}) {
  // if (exaustedLimit??false) {
  //    String exhausted = S.of(context).exhausted_free_quota;
  //   return getRoleAssociatedMessage(
  //     viewRole: viewRole,
  //     forAdmin: '$exhausted ${S.of(context).exhaust_limit_admin_message}',
  //     forCreator: '$exhausted ${S.of(context).exhaust_limit_creator_message}',
  //     forMember: '$exhausted ${S.of(context).exhaust_limit_user_message}',
  //   );
  // }

  // if (isUpdatingPlan) {
  //   return getRoleAssociatedMessage(
  //     viewRole: viewRole,
  //     forAdmin: S.of(context).payment_still_processing,
  //     forCreator: S.of(context).payment_still_processing,
  //     forMember: S.of(context).limit_badge_contact_admin,
  //   );
  // }

  if (isBillingFailed ?? false) {
    return getRoleAssociatedMessage(
      viewRole: viewRole,
      forAdmin: "Billing Failed, please contact owner. ",
      forCreator: "Billing Failed, please visit web.sevaxapp.com to configure.",
      forMember: S.of(context!).limit_badge_contact_admin,
    );
  }
  if (isSoftDeleteRequested!) {
    return getRoleAssociatedMessage(
      viewRole: viewRole,
      forAdmin: S.of(context!).limit_badge_delete_in_progress,
      forCreator: S.of(context).limit_badge_delete_in_progress,
      forMember: S.of(context).limit_badge_contact_admin,
    );
  }

  return S.of(context!).general_stream_error;
}
