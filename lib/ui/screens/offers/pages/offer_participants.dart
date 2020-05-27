import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

class OfferParticipants extends StatelessWidget {
  final OfferModel offerModel;

  const OfferParticipants({Key key, this.offerModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);
    return SingleChildScrollView(
      child: StreamBuilder<List<OfferParticipantsModel>>(
        stream: _bloc.participants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              alignment: Alignment.center,
              child: Text("No Participants yet"),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ParticipantCard(
                name: snapshot.data[index].participantDetails.fullname,
                imageUrl: snapshot.data[index].participantDetails.photourl,
                bio: snapshot.data[index].participantDetails.bio,

                // rating: double.parse(snapshot.data[index].participantDetails.),
                onMessageTapped: () {
                  onMessageClick(
                    context,
                    SevaCore.of(context).loggedInUser,
                    snapshot.data[index].participantDetails,
                    offerModel.timebankId,
                    offerModel.communityId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void onMessageClick(
    context,
    UserModel loggedInUser,
    ParticipantDetails user,
    String timebankId,
    String communityId,
  ) {
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      photoUrl: loggedInUser.photoURL,
      name: loggedInUser.fullname,
      type: MessageType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevauserid,
      photoUrl: user.photourl,
      name: user.fullname,
      type: MessageType.TYPE_PERSONAL,
    );

    createAndOpenChat(
      context: context,
      timebankId: timebankId,
      sender: sender,
      reciever: reciever,
    );
  }
}
