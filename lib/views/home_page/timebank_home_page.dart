import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_page/widgets/no_group_placeholder.dart';
import 'package:sevaexchange/views/home_page/widgets/timebank_card.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';

class TimebankHomePage extends StatefulWidget {
  final CommunityModel selectedCommunity;
  const TimebankHomePage({Key key, this.selectedCommunity}) : super(key: key);
  @override
  _TimebankHomePageState createState() => _TimebankHomePageState();
}

class _TimebankHomePageState extends State<TimebankHomePage>
    with SingleTickerProviderStateMixin {
  HomeDashBoardBloc _homeDashBoardBloc;
  TabController controller;
  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    _homeDashBoardBloc = BlocProvider.of<HomeDashBoardBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _homeDashBoardBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Your Groups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            child: StreamBuilder<CommunityModel>(
              stream: _homeDashBoardBloc.selectedCommunity,
              builder: (context, snapshot) {
                return getTimebanks(community: snapshot.data);
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 10,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Your Calender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelStyle: TextStyle(color: Colors.grey),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(
                child: Text('Pending '),
              ),
              Tab(
                child: Text('Not Accepted '),
              ),
              Tab(
                child: Text('Completed '),
              ),
            ],
            controller: controller,
            isScrollable: false,
            unselectedLabelColor: Colors.black,
          ),
          Expanded(
            child: MyTaskPage(controller),
          )
        ],
      ),
    );
  }

  Widget getTimebanks({CommunityModel community}) {
    Size size = MediaQuery.of(context).size;

    List<TimebankModel> timebankList = [];
    return StreamBuilder<List<TimebankModel>>(
      stream: FirestoreManager.getTimebanksForUserStream(
        userId: SevaCore.of(context).loggedInUser.sevaUserID,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting ||
            community == null) {
          return Container(
            height: 210,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        timebankList = snapshot.data;
        if (timebankList.length == 1) {
          return NoGroupPlaceHolder();
        }
        return FadeAnimation(
          1.4,
          Container(
            height: size.height * 0.25,
            child: ListView.builder(
              itemCount: timebankList.length,
              itemBuilder: (context, index) {
                TimebankModel timebank = timebankList.elementAt(index);
                if (timebank.id != community.primary_timebank)
                  return TimeBankCard(timebank: timebank);
                return Container();
              },
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 12),
              scrollDirection: Axis.horizontal,
            ),
          ),
        );
      },
    );
  }
}
