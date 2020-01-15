import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class HomeDashBoard extends StatelessWidget {
  HomeDashBoard();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // debugShowCheckedModeBanner: false,
      // title: 'Flutter Demo',
      // theme: ThemeData(
      //   primaryColor: Colors.white,
      // ),
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    controller = TabController(initialIndex: 0, length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            // SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: FadeAnimation(
                          1,
                          Text(
                            "Your Time Bank(s)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'Europa',
                                fontSize: 20),
                          ),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          iconSize: 35,
                          color: Colors.grey,
                          alignment: Alignment.center,
                          onPressed: () {
                            createEditCommunityBloc.updateUserDetails(
                                SevaCore.of(context).loggedInUser);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JoinSubTimeBankView(isFromDash: true,)
                                  /*builder: (context) => TimebankCreate(
                                        timebankId: "",
                                      )*/
                                  //TimeBankAboutView(SevaCore.of(context).loggedInUser.currentTimebank,),
                                  ),
                            );
                          }),
                    ],
                  ),
                  //SizedBox(height: 20,),
                  Column(
                    children: <Widget>[
                      getTimebanks(context: context),
                    ],
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 10,
                    color: Colors.grey[300],
                  ),
                  Container(
                    height: 15,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            StickyHeader(
              header: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, bottom: 10, top: 10),
                      child: Text(
                        'Your Calender',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Europa',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TabBar(
                      labelColor: Colors.black,
                      //labelColor: Colors.white,
                      indicatorColor: Colors.black,
                      tabs: [
                        Tab(child: Text('Pending ')),
                        Tab(
                            child: Text(
                          'Not Accepted ',
                        )),
                        Tab(
                            child: Text(
                          'Completed ',
                        )),
                      ],
                      controller: controller,
                      isScrollable: false,
                      unselectedLabelColor: Colors.black,
                    ),
                  ],
                ),
              ),
              content: Container(
                height: size.height - 180,
                // height: size.height - 10,
                child: MyTaskPage(controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeItem(TimebankModel timebank) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimebankTabsViewHolder.of(
              timebankId: timebank.id,
              timebankModel: timebank,
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      timebank.photoUrl ?? defaultUserImageURL),
                  fit: BoxFit.cover)),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ])),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                timebank.name,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> dropdownList = [];

  Widget getTimebanks({BuildContext context}) {
    Size size = MediaQuery.of(context).size;

    List<TimebankModel> timebankList = [];
    return StreamBuilder<List<TimebankModel>>(
        stream: FirestoreManager.getTimebanksForUserStream(
          userId: SevaCore.of(context).loggedInUser.sevaUserID,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          timebankList = snapshot.data;
          timebankList.forEach((t) {
            dropdownList.add(t.id);
          });

          // Navigator.pop(context);
          print("Length ${dropdownList.length}");

          return FadeAnimation(
              1.4,
              Container(
                height: size.height * 0.25,
                child: ListView.builder(
                  itemCount: timebankList.length,
                  itemBuilder: (context, index) {
                    TimebankModel timebank = timebankList.elementAt(index);

                    return makeItem(timebank);
                  },
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 12),
                  scrollDirection: Axis.horizontal,
                ),
              ));
        });
  }
}
