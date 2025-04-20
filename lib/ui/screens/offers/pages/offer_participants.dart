import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

class OfferParticipants extends StatelessWidget {
  final OfferModel? offerModel;
  final TimebankModel? timebankModel;

  const OfferParticipants({Key? key, this.offerModel, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);
    return SingleChildScrollView(
      child: StreamBuilder<List<OfferParticipantsModel>>(
        stream: _bloc!.participants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              alignment: Alignment.center,
              child: Center(child: Text(S.of(context).no_participants_yet)),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ParticipantCard(
                name: snapshot.data![index].participantDetails!.fullname!,
                imageUrl: snapshot.data![index].participantDetails!.photourl!,
                bio: snapshot.data![index].participantDetails!.bio,
                onImageTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ProfileViewer(
                      timebankId: timebankModel!.id,
                      entityName: timebankModel!.name,
                      isFromTimebank: isPrimaryTimebank(
                          parentTimebankId: timebankModel!.parentTimebankId),
                      userEmail:
                          snapshot.data![index].participantDetails!.email,
                    );
                  }));
                },
                // rating: double.parse(snapshot.data[index].participantDetails.),
                onMessageTapped: () {
                  onMessageClick(
                    context,
                    SevaCore.of(context).loggedInUser,
                    snapshot.data![index].participantDetails!,
                    offerModel!.timebankId!,
                    offerModel!.communityId!,
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
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevauserid,
      photoUrl: user.photourl,
      name: user.fullname,
      type: ChatType.TYPE_PERSONAL,
    );

    List<String> showToCommunities = [];
    try {
      String communityId1 = loggedInUser.currentCommunity!;

      String communityId2 =
          offerModel!.participantDetails![user.sevauserid]['communityId']!;

      if (communityId1.isNotEmpty &&
          communityId2.isNotEmpty &&
          communityId1 != communityId2) {
        showToCommunities.add(communityId1);
        showToCommunities.add(communityId2);
      }
    } catch (e) {
      logger.e(e);
    }

    createAndOpenChat(
      context: context,
      timebankId: timebankId,
      communityId: communityId,
      sender: sender,
      reciever: reciever,
      showToCommunities:
          showToCommunities.isNotEmpty ? showToCommunities : <String>[],
      interCommunity: showToCommunities.isNotEmpty,
      feedId: '', // TODO: Replace with actual feedId if available
      entityId: '', // TODO: Replace with actual entityId if available
      onChatCreate: () {}, // TODO: Replace with actual callback if needed
    );
  }
}
