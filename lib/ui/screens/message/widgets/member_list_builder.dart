import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_card.dart';

class MemberListBuilder extends StatelessWidget {
  final List<ParticipantInfo> infos;
  final ScrollPhysics physics;
  const MemberListBuilder({Key key, this.infos, this.physics})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(12),
      itemCount: infos.length,
      physics: physics,
      shrinkWrap: true,
      itemBuilder: (_, int index) {
        return Container(
          child: MemberCard(
            info: infos[index],
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
  }
}
