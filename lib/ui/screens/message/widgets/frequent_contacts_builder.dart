import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class FrequentContactsBuilder extends StatelessWidget {
  final List<FrequentContactsModel> models;
  final bool showGroup;

  const FrequentContactsBuilder(this.models, this.showGroup);
  @override
  Widget build(BuildContext context) {
    log("lenght ${models.length}");
    return StreamBuilder<List<String>>(
        stream: BlocProvider.of<CreateChatBloc>(context)!.selectedMembers,
        builder: (context, snapshot) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: models.length,
            itemBuilder: (_, index) {
              FrequentContactsModel model = models[index];
              return Offstage(
                offstage: showGroup ? model.isGroupMessage : false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MemberCard(
                    info: model.isGroupMessage
                        ? ParticipantInfo(
                            name: model.chatModel.groupDetails!.name,
                            photoUrl: model.chatModel.groupDetails!.imageUrl,
                          )
                        : model.participantInfo,
                    chatModel: model.chatModel,
                    isSelected: model.isGroupMessage
                        ? false
                        : snapshot.data?.contains(model.participantInfo.id) ??
                            false,
                  ),
                ),
              );
            },
          );
        });
  }
}
