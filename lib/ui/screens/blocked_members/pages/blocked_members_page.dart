import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/blocked_members/bloc/blocked_members_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class BlockedMembersPage extends StatefulWidget {
  @override
  _BlockedMembersPageState createState() => _BlockedMembersPageState();
}

class _BlockedMembersPageState extends State<BlockedMembersPage> {
  BlockedMembersBloc _bloc = BlockedMembersBloc();

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () => _bloc.init(SevaCore.of(context).loggedInUser.sevaUserID),
    );
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).blocked_members,
          style: TextStyle(fontSize: 18),
        ),
        titleSpacing: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _bloc.blockedMembers,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<UserModel>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return LoadingIndicator();
          }
          if (snapshot.data.isEmpty)
            return Center(
              child: Text(
                S.of(context).no_blocked_members,
              ),
            );

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data.length,
            itemBuilder: (_, int index) {
              UserModel blockedUser = snapshot.data[index];
              return InkWell(
                onTap: () {
                  _showUnblocDialog(
                    unblockUserId: blockedUser.sevaUserID,
                    unblockUserEmail: blockedUser.email,
                    name: blockedUser.fullname,
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        blockedUser.photoURL != null
                            ? CustomNetworkImage(blockedUser.photoURL)
                            : CustomAvatar(name: blockedUser.fullname),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text("${blockedUser.fullname}"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUnblocDialog(
      {String unblockUserId, String unblockUserEmail, String name}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (_, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            titlePadding: isLoading
                ? EdgeInsets.symmetric(vertical: 12)
                : EdgeInsets.zero,
            title: Container(
              height: 50,
              child: isLoading
                  ? LoadingIndicator()
                  : FlatButton(
                      child: Text(
                        "${S.of(context).unblock} $name?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () {
                        isLoading = true;
                        setState(() {});
                        _bloc
                            .unblockMember(
                              unblockedUserId: unblockUserId,
                              unblockedUserEmail: unblockUserEmail,
                              userId:
                                  SevaCore.of(context).loggedInUser.sevaUserID,
                              loggedInUserEmail:
                                  SevaCore.of(context).loggedInUser.email,
                            )
                            .then(
                              (_) => Navigator.of(dialogContext).pop(),
                            );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
