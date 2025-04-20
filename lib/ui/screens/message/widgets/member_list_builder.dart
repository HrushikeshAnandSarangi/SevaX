import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class MemberListBuilder extends StatelessWidget {
  final List<ParticipantInfo>? infos;
  final ScrollPhysics? physics;

  const MemberListBuilder({Key? key, this.infos, this.physics})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: BlocProvider.of<CreateChatBloc>(context)!.selectedMembers,
      builder: (context, snapshot) {
        return ListView.separated(
          padding: EdgeInsets.all(12),
          itemCount: infos!.length,
          physics: physics,
          shrinkWrap: true,
          itemBuilder: (_, int index) {
            return Container(
              child: MemberCard(
                info: infos![index],
                isSelected: snapshot.data?.contains(
                      infos![index].id,
                    ) ??
                    false,
              ),
            );
          },
          separatorBuilder: (_, int index) {
            return Divider(
              indent: 55,
              height: 8,
            );
          },
        );
      },
    );
  }
}
