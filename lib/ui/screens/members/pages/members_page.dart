import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/members/bloc/join_request_bloc.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/join_request_section_builder.dart';
import 'package:sevaexchange/ui/screens/members/pages/member_section_builder.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_navigator_widget.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class TimebankCombinedWithMembers {
  final TimebankModel timebank;
  final List<UserModel> members;

  TimebankCombinedWithMembers(this.timebank, this.members);
}

enum MemberType { CREATOR, ADMIN, MEMBER, OWNER }
enum UsersSection { ADMINS, MEMBERS, OWNERS }
enum ActionType { PROMOTE, DEMOTE, REMOVE, ADD, DONATE, EXIT }

Map<MemberType, List<ActionType>> actionPermission = {
  MemberType.CREATOR: [
    ActionType.ADD,
    ActionType.REMOVE,
    ActionType.PROMOTE,
    ActionType.DEMOTE,
    ActionType.DONATE,
  ],
  MemberType.ADMIN: [
    ActionType.ADD,
    ActionType.REMOVE,
    ActionType.PROMOTE,
    ActionType.DEMOTE,
    ActionType.DONATE,
  ],
  MemberType.OWNER: [
    ActionType.ADD,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
            child: Text(
              S.of(context).members,
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.zero,
                child: StreamBuilder<TimebankCombinedWithMembers>(
                  stream: CombineLatestStream.combine2(
                    Provider.of<HomePageBaseBloc>(context, listen: false)
                        .timebank(widget.timebankId),
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
                    bool isAdmin = isAccessAvailable(
                        snapshot.data.timebank, user.sevaUserID);

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
                        (id) => !isAccessAvailable(snapshot.data.timebank, id),
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
                                          horizontal: 40,
                                        ),
                                        child: Text(
                                          S.of(context).owners,
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
                                    isTimebankReport: snapshot
                                            .data.timebank.parentTimebankId ==
                                        FlavorConfig.values.timebankId,
                                    timebankModel: snapshot.data.timebank,
                                    communityId:
                                        snapshot.data.timebank.communityId,
                                  ),
                                ),
                                SizedBox(height: 8),
                                owners != null && owners.length > 0
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                        ),
                                        child: MemberSectionBuilder(
                                          section: UsersSection.OWNERS,
                                          members: owners,
                                          creatorId:
                                              snapshot.data.timebank.creatorId,
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
                                          horizontal: 40,
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
                                          horizontal: 40,
                                        ),
                                        child: MemberSectionBuilder(
                                          section: UsersSection.ADMINS,
                                          members: admins,
                                          creatorId:
                                              snapshot.data.timebank.creatorId,
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
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
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
                                      child: RaisedButton.icon(
                                          icon: Icon(Icons.add,
                                              color: Colors.white),
                                          label: Text(S.of(context).add),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            if (isPrimaryTimebank(
                                              parentTimebankId: snapshot.data
                                                  .timebank.parentTimebankId,
                                            )) {
//TODO
                                            } else {}
                                          }),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Divider(
                                  thickness: 0.5,
                                ),
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  MemberType memberType(TimebankModel model, String userId) {
    if (model.creatorId == userId) {
      return MemberType.CREATOR;
    } else if (model.admins.contains(userId)) {
      return MemberType.ADMIN;
    } else if (model.organizers.contains(userId)) {
      return MemberType.OWNER;
    } else {
      return MemberType.MEMBER;
    }
  }
}
