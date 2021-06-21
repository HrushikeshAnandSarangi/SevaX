import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/add_manual_time/widgets/add_manual_time_button.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/umeshify.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'create_edit_project.dart';

class AboutProjectView extends StatefulWidget {
  final String project_id;
  final TimebankModel timebankModel;

  AboutProjectView({this.project_id, this.timebankModel});

  @override
  _AboutProjectViewState createState() => _AboutProjectViewState();
}

class _AboutProjectViewState extends State<AboutProjectView> {
  ProjectModel projectModel;
  String loggedintimezone = '';
  UserModel user;
  bool isDataLoaded = false;
  @override
  void initState() {
    getData();
    setState(() {});
    super.initState();
  }

  void getData() async {
    await FirestoreManager.getProjectFutureById(projectId: widget.project_id)
        .then((onValue) {
      projectModel = onValue;
      setState(() {
        getUserData();
      });
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getData();
    setState(() {});
  }

  void getUserData() async {
    user =
        await FirestoreManager.getUserForId(sevaUserId: projectModel.creatorId);
    isDataLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isDataLoaded
          ? SingleChildScrollView(
              child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: 180,
                          imageUrl:
                              projectModel.cover_url ?? defaultProjectImageURL,
                          placeholder: (context, url) {
                            return LoadingIndicator();
                          },
                        ),
                      ),
                      Positioned(
                        child: Container(
                          child: CachedNetworkImage(
                            imageUrl: (projectModel.photoUrl == null ||
                                    projectModel.photoUrl == '')
                                ? defaultProjectImageURL
                                : projectModel.photoUrl,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 70,
                            placeholder: (context, url) {
                              return LoadingIndicator();
                            },
                          ),
                        ),
                        left: 13.0,
                        bottom: -38.0,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        projectModel.creatorId ==
                                SevaCore.of(context).loggedInUser.sevaUserID
                            ? Container(
                                width: double.infinity,
                                child: FlatButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateEditProject(
                                          timebankId: widget.timebankModel.id,
                                          isCreateProject: false,
                                          projectId: projectModel.id,
                                          projectTemplateModel: null,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    S.of(context).edit,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Europa',
                                        fontWeight: FontWeight.bold,
                                        color: FlavorConfig
                                            .values.theme.primaryColor,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              )
                            : Container(),
                        headingText(S.of(context).title),
                        Text(projectModel.name ?? ""),
                        headingText(S.of(context).mission_statement),
                        SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                                getTimeFormattedString(
                                  projectModel.startTime,
                                ),
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            SizedBox(width: 2),
                            Icon(
                              Icons.remove,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              getTimeFormattedString(
                                projectModel.endTime,
                              ),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(projectModel.description ?? ""),
                        (projectModel.registrationLink == null ||
                                projectModel.registrationLink == '')
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  headingText(S.of(context).registration_link),
                                  SizedBox(height: 10),
                                  Umeshify(
                                    text: projectModel.registrationLink,
                                    onOpen: (link) async {
                                      if (await canLaunch(link)) {
                                        await launch(link);
                                      }
                                    },
                                  ),
                                ],
                              ),
                        headingText(S.of(context).organizer),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            UserProfileImage(
                              photoUrl: user.photoURL,
                              email: user.email,
                              userId: user.sevaUserID,
                              height: 60,
                              width: 60,
                              timebankModel: widget.timebankModel,
                            ),
                            SizedBox(width: 10),
                            Text(user.fullname ?? ""),
                            SizedBox(width: 30),
                            Text(
                              timeAgo
                                  .format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          projectModel.createdAt),
                                      locale: Locale(AppConfig.prefs
                                              .getString('language_code'))
                                          .toLanguageTag())
                                  .replaceAll('hours ago', 'h'),
                              style: TextStyle(
                                fontFamily: 'Europa',
                                color: Colors.black38,
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            projectModel.creatorId ==
                                    SevaCore.of(context).loggedInUser.sevaUserID
                                ? addManualTime
                                : Container(),
                            utils.isDeletable(
                              contentCreatorId: projectModel.creatorId,
                              context: context,
                              communityCreatorId: widget.timebankModel
                                      .managedCreatorIds.isNotEmpty
                                  ? widget.timebankModel.managedCreatorIds
                                      .elementAt(0)
                                  : isPrimaryTimebank(
                                          parentTimebankId: widget
                                              .timebankModel.parentTimebankId)
                                      ? widget.timebankModel.creatorId
                                      : widget.timebankModel.managedCreatorIds
                                          .first,
                              timebankCreatorId: widget.timebankModel.creatorId,
                            )
                                ? deleteProject
                                : Container(),
                          ],
                        )
                      ],
                    ),
                  ),
                ])))
          : LoadingIndicator(),
    );
  }

  Widget get addManualTime {
    return TransactionsMatrixCheck(
      upgradeDetails: AppConfig.upgradePlanBannerModel.add_manual_time,
      transaction_matrix_type: "add_manual_time",
      child: GestureDetector(
        onTap: () => AddManualTimeButton.onPressed(
          context: context,
          timeFor: ManualTimeType.Project,
          typeId: projectModel.id,
          communityName: widget.timebankModel.name,
          userType: utils.getLoggedInUserRole(
            widget.timebankModel,
            SevaCore.of(context).loggedInUser.sevaUserID,
          ),
          timebankId: widget.timebankModel.parentTimebankId ==
                  FlavorConfig.values.timebankId
              ? widget.timebankModel.id
              : widget.timebankModel.parentTimebankId,
        ),
        child: Container(
          margin: EdgeInsets.only(top: 20),
          child: Text(
            S.of(context).add_manual_time,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget get deleteProject {
    return GestureDetector(
      onTap: () {
        showAdvisoryBeforeDeletion(
          context: context,
          associatedId: widget.project_id,
          softDeleteType: SoftDelete.REQUEST_DELETE_PROJECT,
          associatedContentTitle: projectModel.name,
          email: SevaCore.of(context).loggedInUser.email,
          isAccedentalDeleteEnabled: false,
        ).then((value) {
          if (value) Navigator.of(context).pop();
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          S.of(context).delete_project,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 18),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: FlavorConfig.values.theme.primaryColor,
        ),
      ),
    );
  }
}
