import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/blocked_members/bloc/blocked_members_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class BlockedMembersPage extends StatefulWidget {
  final String timebankId;

  BlockedMembersPage({required this.timebankId});

  @override
  _BlockedMembersPageState createState() => _BlockedMembersPageState();
}

class _BlockedMembersPageState extends State<BlockedMembersPage> {
  BlockedMembersBloc _bloc = BlockedMembersBloc();
  TimebankModel? timebankModel;

  @override
  void initState() {
    getTimebank();

    Future.delayed(
      Duration.zero,
      () => _bloc.init(SevaCore.of(context).loggedInUser.sevaUserID!),
    );

    super.initState();
  }

  Future<void> getTimebank() async {
    timebankModel =
        await FirestoreManager.getTimeBankForId(timebankId: widget.timebankId);
    setState(() {});
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
        backgroundColor: Theme.of(context).primaryColor,
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
          if (snapshot.data?.isEmpty ?? true)
            return Center(
              child: Text(
                S.of(context).no_blocked_members,
              ),
            );

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (_, int index) {
              UserModel? blockedUser = snapshot.data?[index];
              return InkWell(
                onTap: () {
                  _showUnblocDialog(
                    unblockUserId: blockedUser?.sevaUserID ?? '',
                    unblockUserEmail: blockedUser?.email ?? '',
                    name: blockedUser?.fullname ?? 'N/A',
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        if (blockedUser?.photoURL != null)
                          CustomNetworkImage(
                            blockedUser!.photoURL!,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileViewer(
                                    timebankId: timebankModel?.id ?? '',
                                    entityName: timebankModel?.name ?? '',
                                    isFromTimebank: isPrimaryTimebank(
                                        parentTimebankId:
                                            timebankModel!.parentTimebankId!),
                                    userId: blockedUser.sevaUserID!,
                                    userEmail: blockedUser.email!,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          CustomAvatar(
                            name: blockedUser?.fullname ?? 'N/A',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileViewer(
                                    timebankId: timebankModel!.id,
                                    entityName: timebankModel!.name,
                                    isFromTimebank: isPrimaryTimebank(
                                        parentTimebankId:
                                            timebankModel!.parentTimebankId),
                                    userId: blockedUser!.sevaUserID!,
                                    userEmail: blockedUser.email!,
                                  ),
                                ),
                              );
                            },
                          ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text("${blockedUser?.fullname}"),
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
      {required String unblockUserId,
      required String unblockUserEmail,
      required String name}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (_, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            titlePadding: EdgeInsets.symmetric(vertical: 12),
            title: Container(
                child: isLoading
                    ? LoadingIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "${S.of(context).unblock} $name?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Visibility(
                            visible: !isLoading,
                            child: Row(
                              children: <Widget>[
                                Spacer(),
                                CustomTextButton(
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    textColor: Colors.white,
                                    child: Text(
                                      S.of(context).yes,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Europa',
                                      ),
                                    ),
                                    onPressed: () {
                                      isLoading = true;
                                      setState(() {});
                                      _bloc
                                          .unblockMember(
                                            unblockedUserId: unblockUserId,
                                            unblockedUserEmail:
                                                unblockUserEmail,
                                            userId: SevaCore.of(context)
                                                    .loggedInUser
                                                    .sevaUserID ??
                                                '',
                                            loggedInUserEmail:
                                                SevaCore.of(context)
                                                        .loggedInUser
                                                        .email ??
                                                    '',
                                          )
                                          .then(
                                            (_) => Navigator.of(dialogContext)
                                                .pop(),
                                          );
                                    }),
                                CustomTextButton(
                                  child: Text(
                                    S.of(context).no,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Europa',
                                        color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
          ),
        );
      },
    );
  }
}
