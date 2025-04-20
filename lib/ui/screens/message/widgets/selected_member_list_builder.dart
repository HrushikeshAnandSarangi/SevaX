import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_widget.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

class SelectedMemberListBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return StreamBuilder<List<String>>(
      stream: _bloc!.selectedMembers,
      builder: (context, snapshot) {
        if ((snapshot.data?.length ?? 0) <= 0) {
          return Container();
        }
        return Container(
          height: 130,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) {
              return SelectedMemberWidget(
                info: _bloc.allMembers[snapshot.data![index]]!,
                onRemovePressed: () {
                  _bloc.selectMember(
                    _bloc.allMembers[snapshot.data![index]]!.id!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class SelectedMemberWrapBuilder extends StatelessWidget {
  final Map<String, ParticipantInfo>? allParticipants;
  final Stream<List<String>>? selectedParticipants;
  final ValueChanged? onRemovePressed;
  // final CreateChatBloc bloc;
  const SelectedMemberWrapBuilder({
    Key? key,
    this.allParticipants,
    this.selectedParticipants,
    this.onRemovePressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: selectedParticipants,
      builder: (context, snapshot) {
        if ((snapshot.data?.length ?? 0) <= 0) {
          return Container();
        }
        return SingleChildScrollView(
          child: Wrap(
            children: List.generate(
              snapshot.data!.length,
              (index) => SelectedMemberWidget(
                info: allParticipants![snapshot.data![index]]!,
                onRemovePressed: () {
                  onRemovePressed!(snapshot.data![index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class GroupMemberBuilder extends StatelessWidget {
  final List<ParticipantInfo>? participants;
  final Function(String id)? onRemovePressed;
  final bool? isAdmin;
  final TimebankModel? timebankModel;

  GroupMemberBuilder(
      {this.participants,
      this.onRemovePressed,
      this.isAdmin,
      this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
        participants!.length,
        (index) => SelectedMemberWidget(
          timebankModel: timebankModel!,
          info: participants![index],
          isEditable: isAdmin! &&
              participants![index]?.id !=
                  SevaCore.of(context).loggedInUser.sevaUserID,
          onRemovePressed: () => onRemovePressed!(participants![index].id!),
        ),
      ),
    );
  }
}
