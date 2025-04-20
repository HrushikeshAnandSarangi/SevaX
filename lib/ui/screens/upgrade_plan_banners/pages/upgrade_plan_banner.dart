import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/auth/bloc/user_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class UpgradePlanBanner extends StatefulWidget {
  final BannerDetails? details;
  final String? activePlanName;
  final bool? isCommunityPrivate;
  final bool? showAppBar;
//  final TimebankModel timebankModel;

  const UpgradePlanBanner({
    Key? key,
    this.details,
    this.activePlanName,
    this.isCommunityPrivate,
    this.showAppBar = true,
//    this.timebankModel
  })  : assert(details != null),
        super(key: key);

  @override
  _UpgradePlanBannerState createState() => _UpgradePlanBannerState();
}

class _UpgradePlanBannerState extends State<UpgradePlanBanner> {
  final controller = PageController(initialPage: 999);
  final _pageIndicator = BehaviorSubject<int>();
  UserModel? currentUser = null;
  TimebankModel? timebankModel = null;
  Timer? _timer;
  BuildContext? dialogLoadingContext;

  @override
  void initState() {
    if (widget.details!.images!.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
          await controller.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _pageIndicator.add(
            (controller.page)!.toInt() % widget.details!.images!.length,
          );
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageIndicator.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar!
          ? AppBar(
              centerTitle: true,
              title: Text(
                S.of(context).upgrade_plan,
                style: TextStyle(fontSize: 18),
              ),
            )
          : null,
      body: FutureBuilder<TimebankModel?>(
        future: getTimeBankForId(
          timebankId: Provider.of<UserBloc>(context, listen: false)
              .loggedInUser
              .currentTimebank!,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(S.of(context).upgrade_plan_msg1);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: LoadingIndicator(),
              ),
            );
          }
          timebankModel = snapshot.data;
          // currentUser = SevaCore.of(context).loggedInUser;
          currentUser =
              Provider.of<UserBloc>(context, listen: false).loggedInUser;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      TextSpan(
                        text: S.of(context).upgrade_plan_disable_msg1,
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: PageView.builder(
                    controller: controller,
                    // itemCount: widget.details.images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.details!
                            .images![index % widget.details!.images!.length],
                        // fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                StreamBuilder<int>(
                    stream: _pageIndicator.stream,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.details!.images!.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 10,
                              width: 10,
                              color: index == (snapshot.data ?? 0)
                                  ? Colors.grey
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      );
                    }),
                Spacer(),
                Text(
                  widget.details!.message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                Spacer(),
                timebankModel!.creatorId == currentUser!.sevaUserID
                    ? Text(
                        S.of(context).upgrade_plan_disable_msg2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      )
                    : Text(
                        S.of(context).upgrade_plan_disable_msg3,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                Spacer(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}
