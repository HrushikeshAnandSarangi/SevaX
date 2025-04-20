import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/parent_community_message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_community_message.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../../../../labels.dart';

class CommunityMessageCreate extends StatefulWidget {
  final String primaryTimebankId;
  final bool isEditing;
  final ParentCommunityMessageBloc bloc;
  final Function(List<String> selectedTimebanks) onSelected;
  const CommunityMessageCreate({
    Key? key,
    required this.primaryTimebankId,
    required this.isEditing,
    required this.bloc,
    required this.onSelected,
  }) : super(key: key);

  @override
  _CommunityMessageCreateState createState() => _CommunityMessageCreateState();
}

class _CommunityMessageCreateState extends State<CommunityMessageCreate> {
  late ParentCommunityMessageBloc bloc;
  List<String> selectedList = [];
  @override
  void initState() {
    if (widget.bloc != null) {
      bloc = widget.bloc;
    } else {
      bloc = ParentCommunityMessageBloc();
    }
    if (!widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          bloc.init(
            widget.primaryTimebankId,
          );
        },
      );
    } else {
      List<String> list = widget.bloc.getAllSelectedTimebanks();
      selectedList.addAll(list);
      setState(() {});
    }

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).new_comminity_message,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          StreamBuilder<List<String>>(
              stream: bloc.selectedTimebanks,
              builder: (context, snapshot) {
                if ((snapshot.data?.length ?? 0) > 0) {
                  return GestureDetector(
                    onTap: () async {
                      if (widget.isEditing) {
                        Navigator.of(context).pop();
                        widget.onSelected(selectedList);
                      } else {
                        var timebanks = await bloc.selectedTimebanks.first;
                        if (timebanks.length == 1) {
                          var timebank = Provider.of<HomePageBaseBloc>(context,
                                  listen: false)
                              .primaryTimebankModel();
                          bloc.createSingleCommunityChat(
                            context,
                            ParticipantInfo(
                              id: timebank.id,
                              name: timebank.name,
                              photoUrl: timebank.photoUrl,
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateCommunityMessage(
                                bloc: bloc,
                                chatModel:
                                    ChatModel(), // Provide a valid ChatModel instance here
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Text(
                          S.of(context).next,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              })
        ],
      ),
      body: StreamBuilder(
        stream: bloc.childCommunities,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Center(
              child: Text(
                S.of(context).no_child_communities,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              ParentCommunityMessageData community = snapshot.data[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: <Widget>[
                    community.photoUrl != null
                        ? CustomNetworkImage(
                            community.photoUrl,
                            size: 40,
                          )
                        : CustomAvatar(
                            name: community.name,
                            radius: 20,
                          ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(snapshot.data[index].name),
                    ),
                    Checkbox(
                      value: selectedList.contains(community.id),
                      onChanged: (_) {
                        bloc.selectParticipant(community.id);
                        if (selectedList.contains(community.id)) {
                          selectedList.remove(community.id);
                        } else {
                          selectedList.add(community.id);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
