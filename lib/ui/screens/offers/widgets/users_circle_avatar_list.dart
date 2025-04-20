import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class UserCircleAvatarList extends StatelessWidget {
  final int? sizeOfClass;

  const UserCircleAvatarList({Key? key, this.sizeOfClass}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);
    return StreamBuilder<List<OfferParticipantsModel>>(
      stream: _bloc!.participants,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                sizeOfClass == null
                    ? "${snapshot.data!.length} ${S.of(context).people_signed_up_text}"
                    : "${snapshot.data!.length}/$sizeOfClass ${S.of(context).people_signed_up_text}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(4),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: CustomNetworkImage(
                          snapshot.data![index].participantDetails!.photourl ??
                              defaultUserImageURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
