import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class MembersTabView extends StatefulWidget {
  @override
  _MembersTabViewState createState() => _MembersTabViewState();
}

class _MembersTabViewState extends State<MembersTabView> {
  QuerySnapshot? skillsListSnap;
  QuerySnapshot? interestsListSnap;

  @override
  void initState() {
    //  getAllSkillsInterests();
    super.initState();
  }

  void getAllSkillsInterests() async {
    skillsListSnap = await CollectionRef.skills.get();
    interestsListSnap = await CollectionRef.interests.get();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc!.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text(S.of(context).search_something));
          }
          return StreamBuilder<List<UserModel>>(
            stream: Searches.searchMembersOfTimebank(
              queryString: search.data,
              loggedInUser: _bloc.user!,
              currentCommunityOfUser: _bloc.community!,
              //skillsListSnap: skillsListSnap,
              //interestsListSnap: interestsListSnap,
              languageCode: SevaCore.of(context).loggedInUser.language!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(S.of(context).no_search_result_found),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileViewer(
                            userEmail: user.email,
                            timebankId: _bloc.timebank!.id,
                            isFromTimebank: false,
                            entityName: _bloc.timebank!.id,
                          ),
                        ),
                      );
                    },
                    child: MembersCard(
                      name: user.fullname!,
                      photoUrl: user.photoURL!,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MembersCard extends StatelessWidget {
  final String? name;
  final String? photoUrl;

  const MembersCard({Key? key, this.name, this.photoUrl})
      : assert(name != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(photoUrl ?? defaultUserImageURL),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    name!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
