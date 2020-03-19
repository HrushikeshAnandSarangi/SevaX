import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_plan_details.dart';

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
          offstage: _userBloc.community.payment['payment_success'] ?? false,
          child: Container(
            height: 20,
            width: double.infinity,
            color: Colors.red,
            alignment: Alignment.center,
            child: Text(
              isAdmin
                  ? 'Payment Failed : ' +
                          _userBloc.community.payment['message'] ??
                      "Payment Data Syncing"
                  : "Actions not allowed, Please contact admin",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class TransactionLimitCheck extends StatelessWidget {
  final Widget child;

  const TransactionLimitCheck({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProvider.of<UserDataBloc>(context);

    return StreamBuilder(
      stream: _userBloc.comunityStream,
      builder: (context, AsyncSnapshot<CommunityModel> snapshot) {
        bool isAdmin =
            _userBloc.community.admins.contains(_userBloc.user.sevaUserID);
        return GestureDetector(
          onTap: () {
            _showDialog(context, isAdmin, _userBloc.user);
          },
          child: AbsorbPointer(
            absorbing:
                // Actual code  !(_userBloc.community.payment['payment_success'] ?? false),
                !(_userBloc.community.payment['payment_success'] ?? false),
            child: child,
          ),
        );
      },
    );
  }

  void _showDialog(context, bool isAdmin, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print(isAdmin);
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
                isAdmin
                    ? 'Billing Failed, Click below to configure billing'
                    : 'Action not allowed, please contact the admin',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Offstage(
                offstage: !isAdmin,
                child: FlatButton(
                  color: Theme.of(context).accentColor,
                  child: new Text(
                    "Configure Billing",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BillingPlanDetails(
                          autoImplyLeading: true,
                          user: user,
                          isPlanActive: false,
                          // planName: "grande_plan",
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              FlatButton(
                color: Theme.of(context).accentColor,
                child: new Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[

              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }
}
