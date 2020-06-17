import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';

class SelectedMemberWidget extends StatelessWidget {
  final ParticipantInfo info;
  final CreateChatBloc bloc;

  const SelectedMemberWidget({Key key, this.info, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                child: CustomNetworkImage(
                  info.photoUrl,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      bloc.selectMember(info.id);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(info.name.split(' ')[0]),
        ],
      ),
    );
  }
}
