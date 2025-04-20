import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_card.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class GroupMembersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return StreamBuilder(
      stream: _bloc!.timebanksOfUser,
      builder: (_, AsyncSnapshot<List<TimebankModel>> snapshot) {
        if (snapshot.data == null) {
          return LoadingIndicator();
        }
        return StreamBuilder<List<String>>(
          stream: _bloc.selectedMembers,
          builder: (context, selectedMembers) {
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (_, int index) {
                TimebankModel model = snapshot.data![index];
                List<ParticipantInfo> members = [];

                model.members.forEach((element) {
                  if (_bloc.allMembers.containsKey(element)) {
                    if (_bloc.allMembers[element] != null) {
                      members.add(_bloc.allMembers[element]!);
                    }
                  }
                });

                return HideWidget(
                  hide: members.isEmpty,
                  secondChild: Container(),
                  child: ExpansionTile(
                    leading: CustomNetworkImage(
                      model.photoUrl ?? defaultGroupImageURL,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            model.name,
                            maxLines: 1,
                          ),
                        ),
                        Offstage(
                          offstage: !BlocProvider.of<CreateChatBloc>(context)!
                              .isSelectionEnabled,
                          child: CustomTextButton(
                            child: Text(S.of(context).select_all),
                            textColor: Theme.of(context).primaryColor,
                            onPressed: () {
                              model.members.forEach((element) {
                                if (_bloc.allMembers.containsKey(element)) {
                                  BlocProvider.of<CreateChatBloc>(context)!
                                      .selectMember(element);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    children: members
                        .map(
                          (info) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 4),
                            child: MemberCard(
                              info: info,
                              isSelected:
                                  selectedMembers.data?.contains(info.id) ??
                                      false,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
