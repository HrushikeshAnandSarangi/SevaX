import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';

class MembersTabView extends StatefulWidget {

  @override
  _MembersTabViewState createState() => _MembersTabViewState();
}

class _MembersTabViewState extends State<MembersTabView> {
  QuerySnapshot skillsListSnap;
  QuerySnapshot interestsListSnap;

  void initState(){
    getAllSkillsInterests();
  }
  void getAllSkillsInterests () async {
    skillsListSnap = await Firestore.instance.collection('skills').getDocuments();
    interestsListSnap = await Firestore.instance.collection('interests').getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<List<UserModel>>(
            stream: Searches.searchMembersOfTimebank(
              queryString: search.data,
              loggedInUser: _bloc.user,
              currentCommunityOfUser: _bloc.community,
              skillsListSnap: skillsListSnap,
              interestsListSnap: interestsListSnap,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data == null || snapshot.data.isEmpty) {
                print("===>> ${snapshot.data}");
                return Center(
                  child: Text("No data found !"),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileViewer(
                            userEmail: user.email,
                            timebankId: _bloc.timebank.id,
                          ),
                        ),
                      );
                    },
                    child: MembersCard(
                      name: user.fullname,
                      photoUrl: user.photoURL,
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
  final String name;
  final String photoUrl;

  const MembersCard({Key key, this.name, this.photoUrl})
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
                    name,
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
