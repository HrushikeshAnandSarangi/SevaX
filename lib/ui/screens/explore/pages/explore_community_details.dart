import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_community_details_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

class ExploreCommunityDetails extends StatefulWidget {
  final String communityId;

  const ExploreCommunityDetails({Key key, this.communityId}) : super(key: key);

  @override
  _ExploreCommunityDetailsState createState() =>
      _ExploreCommunityDetailsState();
}

class _ExploreCommunityDetailsState extends State<ExploreCommunityDetails> {
  ExploreCommunityDetailsBloc _bloc = ExploreCommunityDetailsBloc();
  @override
  void initState() {
    _bloc.init(widget.communityId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CommunityModel>(
      stream: _bloc.community,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text('something went wrong'),
          );
        }
        var community = snapshot.data;
        return ExplorePageViewHolder(
          hideHeader: Provider.of<UserModel>(context) != null,
          hideFooter: true,
          appBarTitle: community.name,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: AspectRatio(
                  aspectRatio: 4 / 2,
                  child: Image.network(
                    community.logo_url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part of SevaX Global Network of Communities',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    community.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            "https://www.adobe.com/content/dam/cc/us/en/creative-cloud/photography/discover/landscape-photography/CODERED_B1_landscape_P2d_714x348.jpg.img.jpg",
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tania Richerdson',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Organizer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        FlatButton(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('Message'),
                          ),
                          onPressed: () {},
                        ),
                        FlatButton(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(S.of(context).join),
                          ),
                          onPressed: () {
                            if (Provider.of<UserModel>(context) != null) {
                            } else {
                              showSignInAlertMessage(
                                context: context,
                                message:
                                    'Please Sign In/Sign up to access ${community.name}',
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("asbdkjab"),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "About us",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      community.about,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: MemberAvatarListWithCount(
                  userIds: community.members,
                  radius: 22,
                ),
              ),
              StreamBuilder<List<ProjectModel>>(
                stream: _bloc.events,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.data.isEmpty) {
                    return Container();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "Upcoming Events",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var event = snapshot.data[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 250,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      event.photoUrl ?? defaultProjectImageURL,
                                      fit: BoxFit.cover,
                                      width: 250,
                                      height: 180,
                                    ),
                                    Text(
                                      event.address ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      event.description,
                                    ),
                                    SizedBox(height: 4),
                                    MemberAvatarListWithCount(
                                      userIds:
                                          event.associatedmembers.keys.toList(),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat('EEEE, d MMM h:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          event.startTime,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
              StreamBuilder<List<RequestModel>>(
                stream: _bloc.requests,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.data.isEmpty) {
                    return Container();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "Latest Requests",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var request = snapshot.data[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 250,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      "https://www.adobe.com/content/dam/cc/us/en/creative-cloud/photography/discover/landscape-photography/CODERED_B1_landscape_P2d_714x348.jpg.img.jpg",
                                      fit: BoxFit.cover,
                                      width: 250,
                                      height: 180,
                                    ),
                                    Text(
                                      request.address ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(request.title),
                                    SizedBox(height: 4),
                                    MemberAvatarListWithCount(
                                      userIds: request.approvedUsers,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat('EEEE, d MMM h:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          request.requestStart,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

void showSignInAlertMessage({BuildContext context, String message}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Access not available'),
        content: Text(message),
        actions: [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).ok)),
        ],
      );
    },
  );
}
