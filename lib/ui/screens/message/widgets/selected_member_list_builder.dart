import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_widget.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class SelectedMemberListBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return StreamBuilder<List<String>>(
      stream: _bloc.selectedMembers,
      builder: (context, snapshot) {
        print("al member ${_bloc.allMembers}");
        if ((snapshot.data?.length ?? 0) <= 0) {
          return Container();
        }
        return Container(
          height: 110,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              return SelectedMemberWidget(
                info: _bloc.allMembers[snapshot.data[index]],
                bloc: _bloc,
              );
            },
          ),
        );
      },
    );
  }
}

class SelectedMemberWrapBuilder extends StatelessWidget {
  final CreateChatBloc bloc;

  const SelectedMemberWrapBuilder({Key key, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: bloc.selectedMembers,
      builder: (context, snapshot) {
        print("al member ${bloc.allMembers}");
        if ((snapshot.data?.length ?? 0) <= 0) {
          return Container();
        }
        return Container(
          height: 110,
          child: Wrap(
            children: List.generate(
              snapshot.data.length,
              (index) => SelectedMemberWidget(
                info: bloc.allMembers[snapshot.data[index]],
                bloc: bloc,
              ),
            ),
          ),
        );
      },
    );
  }
}
