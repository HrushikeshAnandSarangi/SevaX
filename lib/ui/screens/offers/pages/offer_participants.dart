import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
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
                    SevaCore.of(context).loggedInUser.email,
                    snapshot.data[index].participantDetails.email,
                    offerModel.timebankId,
                    offerModel.communityId,
                  );
                },
              );
            },
          );
        },
      ),
      // child: Column(
      //   children: <Widget>[
      //     SizedBox(height: 10),
      //     // Container(
      //     //   width: MediaQuery.of(context).size.width,
      //     //   padding: EdgeInsets.symmetric(vertical: 8),
      //     //   color: Colors.grey[300],
      //     //   child: Center(
      //     //     child: Text(
      //     //       "Ensure to recieve credits after the class is completed",
      //     //       style: TextStyle(color: Colors.grey[700]),
      //     //     ),
      //     //   ),
      //     // ),

      //   ],
      // ),
    );
  }

  void onMessageClick(context, String senderEmail, String recieverEmail,
      String timebankId, String communityId) {
    List users = [senderEmail, recieverEmail];
    users.sort();
    ChatModel model = ChatModel();
    model.user1 = users[0];
    model.user2 = users[1];
    model.timebankId = timebankId;
    model.communityId = communityId;
    createChat(chat: model);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(
          useremail: recieverEmail,
          chatModel: model,
        ),
      ),
    );
  }
}
