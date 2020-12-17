import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_card.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class GroupMembersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return StreamBuilder(
      stream: _bloc.timebanksOfUser,
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
              itemCount: snapshot.data.length,
              itemBuilder: (_, int index) {
                TimebankModel model = snapshot.data[index];

                return ExpansionTile(
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
                        offstage: !BlocProvider.of<CreateChatBloc>(context)
                            .isSelectionEnabled,
                        child: FlatButton(
                          child: Text('Select All'),
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            model.members.forEach((element) {
                              if (_bloc.allMembers.containsKey(element)) {
                                BlocProvider.of<CreateChatBloc>(context)
                                    .selectMember(element);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  children: List.generate(
                    model.members.length,
                    (idx) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: _bloc.allMembers.containsKey(model.members[idx])
                          ? MemberCard(
                              info: _bloc.allMembers[model.members[idx]],
                              isSelected: selectedMembers.data
                                      ?.contains(model.members[idx]) ??
                                  false,
                            )
                          : Container(),
                    ),
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
