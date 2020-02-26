import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

import '../../timebank_content_holder.dart';

class TimeBankCard extends StatelessWidget {
  final TimebankModel timebank;
  final UserDataBloc userBloc;

  const TimeBankCard({Key key, this.timebank, this.userBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              bloc:userBloc,
                          child: TimebankRouter(
                timebankId: timebank.id,
                timebankModel: timebank,
              ),
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      timebank.photoUrl ?? defaultUserImageURL),
                  fit: BoxFit.cover)),
          child: Container(
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
        ),
      ),
    );
  }
}
