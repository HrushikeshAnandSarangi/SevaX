import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class GroupCard extends StatelessWidget {
  final TimebankModel? model;

  const GroupCard({Key? key, this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final createChatBloc = BlocProvider.of<CreateChatBloc>(context);
    return StreamBuilder<List<String>>(
      stream: createChatBloc?.selectedMembers,
      builder: (context, snapshot) {
        final selectedMembers = snapshot.data ?? [];
        return Container(
          child: GestureDetector(
            child: Row(
              children: <Widget>[
                CustomNetworkImage(
                  // info.photoUrl ??
                  "https://pluspng.com/img-png/user-png-icon-male-user-icon-512.png",
                  size: 40,
                ),
                SizedBox(width: 12),
                Expanded(child: Text(model?.name ?? "")),
                // Checkbox(
                //   value: selectedMembers.contains(model?.id),
                //   onChanged: (value) {},
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
