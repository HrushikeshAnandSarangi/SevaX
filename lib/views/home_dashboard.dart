import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_page/timebank_feeds.dart';
import 'package:sevaexchange/views/home_page/timebank_home_page.dart';

import 'messages/timebank_chats.dart';

class HomeDashBoard extends StatelessWidget {
  HomeDashBoard();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class DashboardTabsViewHolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(text: "Alaska Timebank"),
                Tab(text: "Feeds"),
                Tab(text: "Requests"),
                Tab(text: "Offers"),
                Tab(text: "About"),
                Tab(text: "Members"),
              ],
            ),
            centerTitle: true,
            title: Text(
              'Alaska Timebank',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          body: TabBarView(
            children: [
              MyHomePage(),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
              Icon(Icons.directions_car),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
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

  HomeDashBoardBloc _homeDashBoardBloc = HomeDashBoardBloc();

  CommunityModel selectedCommunity;

  @override
  void initState() {
    controller = TabController(initialIndex: 0, length: 3, vsync: this);
    super.initState();
    Future.delayed(
      Duration.zero,
      () => _homeDashBoardBloc
          .getAllCommunities(SevaCore.of(context).loggedInUser),
    );
  }

  @override
  void dispose() {
    _homeDashBoardBloc.dispose();
    super.dispose();
  }

  void setCurrentCommunity(List<CommunityModel> data) {
    if (data != null)
      data.forEach((model) {
        if (model.id == SevaCore.of(context).loggedInUser.currentCommunity) {
          selectedCommunity = model;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _homeDashBoardBloc,
      child: DefaultTabController(
        length: 7,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: StreamBuilder<List<CommunityModel>>(
              stream: _homeDashBoardBloc.communities,
              builder: (context, snapshot) {
                setCurrentCommunity(snapshot.data);
                return snapshot.data != null
                    ? DropdownButtonHideUnderline(
                        child: DropdownButton<CommunityModel>(
                        value: selectedCommunity,
                        onChanged: (v) {
                          SevaCore.of(context).loggedInUser.currentCommunity =
                              v.id;
                          _homeDashBoardBloc.setDefaultCommunity(
                            context: context,
                            community: v,
                            oldCommunityId: selectedCommunity.id,
                          );
                          setState(() {
                            selectedCommunity = v;
                          });
                        },
                        items: List.generate(
                          snapshot.data.length,
                          (index) => DropdownMenuItem(
                            value: snapshot.data[index],
                            child: Text(
                              snapshot.data[index].name,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ))
                    : Container();
              },
            ),
            bottom: TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(
                    text:
                        "${selectedCommunity != null ? selectedCommunity.name : ''} Timebank"),
                Tab(text: "Feeds"),
                Tab(text: "Requests"),
                Tab(text: "Offers"),
                Tab(text: "About"),
                Tab(text: "Members"),
                Tab(text: "Messages"),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              TimebankHomePage(
                selectedCommunity: selectedCommunity,
              ),
              TimebankFeeds(),
              TimebankFeeds(),
              TimebankFeeds(),
              TimebankFeeds(),
              TimebankFeeds(),
              TimebankChatListView(
                timebankId: "9ecec05e-71fd-456e-9f6d-35798f41bdf5",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SafeArea(
//       child: ListView(
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 2),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Padding(
//                       padding: EdgeInsets.all(20),
//                       child: FadeAnimation(
//                         1,
//                         Text(
//                           "Your Groups",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                               fontFamily: 'Europa',
//                               fontSize: 20),
//                         ),
//                       ),
//                     ),
//                     Spacer(),
//                     IconButton(
//                         icon: Icon(Icons.add_circle_outline),
//                         iconSize: 35,
//                         color: Colors.grey,
//                         alignment: Alignment.center,
//                         onPressed: () {
//                           createEditCommunityBloc.updateUserDetails(
//                               SevaCore.of(context).loggedInUser);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => TimebankCreate(
//                                 timebankId: SevaCore.of(context)
//                                     .loggedInUser
//                                     .currentTimebank,
//                               ),
//                             ),
//                           );
//                         }),
//                   ],
//                 ),
//                 //SizedBox(height: 20,),
//                 Column(
//                   children: <Widget>[
//                     getTimebanks(context: context),
//                   ],
//                 ),

//                 SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                   height: 10,
//                   color: Colors.grey[300],
//                 ),
//                 Container(
//                   height: 15,
//                   color: Colors.white,
//                 ),
//               ],
//             ),
//           ),
//           StickyHeader(
//             header: Container(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 20, bottom: 10, top: 10),
//                     child: Text(
//                       'Your Calender',
//                       textAlign: TextAlign.start,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontFamily: 'Europa',
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   TabBar(
//                     labelColor: Theme.of(context).primaryColor,
//                     unselectedLabelStyle: TextStyle(color: Colors.grey),
//                     labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                     //labelColor: Colors.white,
//                     indicatorColor: Theme.of(context).primaryColor,
//                     tabs: [
//                       Tab(
//                         child: Text('Pending '),
//                       ),
//                       Tab(
//                         child: Text('Not Accepted '),
//                       ),
//                       Tab(
//                         child: Text('Completed '),
//                       ),
//                     ],
//                     controller: controller,
//                     isScrollable: false,
//                     unselectedLabelColor: Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//             content: Container(
//               height: size.height - 180,
//               // height: size.height - 10,
//               child: MyTaskPage(controller),
//             ),
//           ),
//         ],
//       ),
//     ),
