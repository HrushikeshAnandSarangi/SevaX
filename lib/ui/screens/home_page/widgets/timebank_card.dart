import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';

class TimeBankCard extends StatelessWidget {
  final TimebankModel timebank;
  final UserDataBloc user;

  TimeBankCard({Key? key, required this.timebank, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _user = BlocProvider.of<UserDataBloc>(context);

    return InkWell(
      onTap: () {
        Provider.of<HomePageBaseBloc>(context, listen: false)
            .changeTimebank(timebank);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_context) => BlocProvider(
              bloc: _user,
              child: BlocProvider(
                bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                child: TabarView(
                  userModel: SevaCore.of(context).loggedInUser,
                  timebankModel: timebank,
                ),
              ),
            ),
          ),
        ).then((value) {
          Provider.of<HomePageBaseBloc>(context, listen: false)
              .switchToPreviousTimebank();
        });
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: CachedNetworkImageProvider(
                    timebank.photoUrl ?? defaultGroupImageURL),
                fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.2),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    timebank.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        fontSize: 14),
                  ),
                ),
              ),
              timebank.sponsored
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'images/icons/verified.png',
                        color: Colors.orange,
                        height: 28,
                        width: 28,
                      ))
                  : Offstage(),
            ],
          ),
        ),
      ),
    );
  }
}
