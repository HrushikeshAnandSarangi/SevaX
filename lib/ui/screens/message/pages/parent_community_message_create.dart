import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/parent_community_message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_community_message.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Message community',
          style: TextStyle(fontSize: 18),
        ),
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
              return InkWell(
                onTap: () {
                  bloc.selectParticipant(snapshot.data[index].id);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateCommunityMessage(
                        bloc: bloc,
                      ),
                    ),
                  );
                },
                child: Text(snapshot.data[index].name),
              );
            },
          );
        },
      ),
    );
  }
}
