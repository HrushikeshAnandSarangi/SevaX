import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/parent_community_message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_community_message.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunityMessageCreate extends StatefulWidget {
  final String primaryTimebankId;
  const CommunityMessageCreate({Key key, this.primaryTimebankId})
      : super(key: key);

  @override
  _CommunityMessageCreateState createState() => _CommunityMessageCreateState();
}

class _CommunityMessageCreateState extends State<CommunityMessageCreate> {
  ParentCommunityMessageBloc bloc = ParentCommunityMessageBloc();
  List<String> selectedList = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        bloc.init(
          Provider.of<HomePageBaseBloc>(context, listen: false)
              .primaryTimebankModel()
              .id,
        );
      },
    );
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
          'Message community',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          StreamBuilder<List<String>>(
              stream: bloc.selectedTimebanks,
              builder: (context, snapshot) {
                if ((snapshot.data?.length ?? 0) > 0) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateCommunityMessage(
                            bloc: bloc,
                          ),
                        ),
                      );
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
              child: Text('No Child Communities'),
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
