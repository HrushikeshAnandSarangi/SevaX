import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/ui/screens/members/bloc/join_request_bloc.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/join_request_section_builder.dart';
import 'package:sevaexchange/ui/screens/members/pages/member_section_builder.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_navigator_widget.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebanks/invite_members.dart';
import 'package:sevaexchange/views/timebanks/invite_members_group.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class TimebankCombinedWithMembers {
  final TimebankModel timebank;
  final List<UserModel> members;

  TimebankCombinedWithMembers(this.timebank, this.members);
}

enum MemberType { CREATOR, ADMIN, MEMBER, SUPER_ADMIN }
enum UsersSection { ADMINS, MEMBERS, OWNERS }
enum ActionType { PROMOTE, DEMOTE, REMOVE, DONATE, EXIT }

Map<MemberType, List<ActionType>> actionPermission = {
  MemberType.CREATOR: [
    ActionType.REMOVE,
    ActionType.PROMOTE,
    ActionType.DEMOTE,
    ActionType.DONATE,
  ],
  MemberType.ADMIN: [
    ActionType.REMOVE,
    ActionType.PROMOTE,
    ActionType.DEMOTE,
    ActionType.DONATE,
  ],
  MemberType.SUPER_ADMIN: [
    ActionType.REMOVE,
    ActionType.PROMOTE,
    ActionType.DEMOTE,
    ActionType.DONATE,
  ],
  MemberType.MEMBER: [
    ActionType.EXIT,
  ],
};

class MembersPage extends StatefulWidget {
  final String timebankId;

  const MembersPage({Key key, this.timebankId}) : super(key: key);

  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  JoinRequestBloc joinRequestBloc = JoinRequestBloc();

  @override
  void initState() {
    joinRequestBloc.init(widget.timebankId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _membersBloc = Provider.of<MembersBloc>(context, listen: false);
    final ProgressDialog _progress = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      customBody: Container(
        width: 100,
        height: 100,
        child: LoadingIndicator(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StreamBuilder<TimebankCombinedWithMembers>(
            stream: CombineLatestStream.combine2(
              TimebankRepository.getTimebankStream(widget.timebankId),
              _membersBloc.members,
              (a, b) => TimebankCombinedWithMembers(a, b),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                logger.e(snapshot.error);
                return Text(S.of(context).general_stream_error);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: LoadingIndicator());
              }

              UserModel user = SevaCore.of(context).loggedInUser;
              bool isAdmin =
                  isAccessAvailable(snapshot.data.timebank, user.sevaUserID);

              // bool isOwner =
              //     snapshot.data.timebank.creatorId == user.sevaUserID ||
              //         snapshot.data.timebank.organizers
              //             .contains(user.sevaUserID);

              List<UserModel> owners = List.generate(
                snapshot.data.timebank.organizers.length,
                (index) => _membersBloc.getMemberFromLocalData(
                  userId: snapshot.data.timebank.organizers[index],
                ),
              );

              List<UserModel> admins = List.generate(
                snapshot.data.timebank.admins.length,
                (index) => _membersBloc.getMemberFromLocalData(
                  userId: snapshot.data.timebank.admins[index],
                ),
              );

              List<String> memberIds = List<String>.from(
                snapshot.data.timebank.members.where(
                  (id) => !isMemberAnAdmin(snapshot.data.timebank, id),
                ),
              );

              List<UserModel> members = List.generate(
                memberIds.length,
                (index) => _membersBloc.getMemberFromLocalData(
                  userId: memberIds[index],
                ),
              );
              if (admins != null && admins.length > 0) {
                admins.removeWhere((element) => snapshot
                    .data.timebank.organizers
                    .contains(element.sevaUserID));
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          owners != null && owners.length > 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    S.of(context).super_admins,
                                    //   S.of(context).owners,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 8),
                          HideWidget(
                            hide: !isAdmin,
                            child: ReportedMemberNavigatorWidget(
                              isTimebankReport:
                                  snapshot.data.timebank.parentTimebankId ==
                                      FlavorConfig.values.timebankId,
                              timebankModel: snapshot.data.timebank,
                              communityId: snapshot.data.timebank.communityId,
                            ),
                          ),
                          SizedBox(height: 8),
                          owners != null && owners.length > 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: MemberSectionBuilder(
                                    section: UsersSection.OWNERS,
                                    members: owners,
                                    creatorId: snapshot.data.timebank.creatorId,
                                    isTimebankSection: true,
                                    type: memberType(
                                      snapshot.data.timebank,
                                      user.sevaUserID,
                                    ),
                                    timebank: snapshot.data.timebank,
                                    progress: _progress,
                                  ),
                                )
                              : Offstage(),
                          admins != null && admins.length > 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    S.of(context).admins,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 8),
                          admins != null && admins.length > 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: MemberSectionBuilder(
                                    section: UsersSection.ADMINS,
                                    members: admins,
                                    creatorId: snapshot.data.timebank.creatorId,
                                    isTimebankSection: true,
                                    type: memberType(
                                      snapshot.data.timebank,
                                      user.sevaUserID,
                                    ),
                                    timebank: snapshot.data.timebank,
                                    progress: _progress,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    HideWidget(
                      hide: !isAdmin,
                      child: JoinRequestSectionBuilder(
                        joinRequestBloc: joinRequestBloc,
                        timebankModel: snapshot.data.timebank,
                      ),
                    ),
                    Visibility(
                      visible: snapshot.data.timebank.id !=
                          FlavorConfig.values.timebankId,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  S.of(context).members,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                HideWidget(
                                  hide: !isAdmin,
                                  child: GestureDetector(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 10,
                                      child: Image.asset(
                                        "lib/assets/images/add.png",
                                      ),
                                    ),
                                    onTap: () => _navigateToAddMembers(
                                      snapshot.data.timebank,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                              ],
                            ),
                            SizedBox(height: 20),
                            MemberSectionBuilder(
                              section: UsersSection.MEMBERS,
                              creatorId: snapshot.data.timebank.creatorId,
                              members: members,
                              type: memberType(
                                snapshot.data.timebank,
                                user.sevaUserID,
                              ),
                              timebank: snapshot.data.timebank,
                              progress: _progress,
                              onMemberExit: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SwitchTimebank(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToAddMembers(TimebankModel model) {
    if (isPrimaryTimebank(
      parentTimebankId: model.parentTimebankId,
    )) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InviteAddMembers(
            model,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InviteMembersGroup(
            parenttimebankid: SevaCore.of(context).loggedInUser.currentTimebank,
            timebankModel: model,
          ),
        ),
      );
    }
  }

  MemberType memberType(TimebankModel model, String userId) {
    if (model.creatorId == userId) {
      return MemberType.CREATOR;
    } else if (model.admins.contains(userId)) {
      return MemberType.ADMIN;
    } else if (model.organizers.contains(userId)) {
      return MemberType.SUPER_ADMIN;
    } else {
      return MemberType.MEMBER;
    }
  }
}
