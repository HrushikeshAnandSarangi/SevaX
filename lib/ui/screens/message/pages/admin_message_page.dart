import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/admin_message_card.dart';
import 'package:sevaexchange/ui/screens/message/widgets/community_messages.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class AdminMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HideWidget(
            hide: isPrimaryTimebank(
                parentTimebankId:
                    SevaCore.of(context).loggedInUser.currentTimebank ?? ''),
            child: Container(
              height: 50,
            ),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommunityMessages(
                        bloc: _bloc!,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).go_to_community_chat,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                    )
                  ],
                ),
              ),
            ),
          ),
          StreamBuilder<List<AdminMessageWrapperModel>>(
            stream: _bloc!.adminMessage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text(S.of(context).no_message));
              }
              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  AdminMessageWrapperModel model = snapshot.data![index];
                  return AdminMessageCard(
                    model: model,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
