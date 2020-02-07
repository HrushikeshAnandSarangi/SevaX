import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_page/widgets/no_group_placeholder.dart';
import 'package:sevaexchange/views/home_page/widgets/timebank_card.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';

class TimebankHomePage extends StatefulWidget {
  final SelectedCommuntityGroup selectedCommuntityGroup;

  const TimebankHomePage({Key key, this.selectedCommuntityGroup})
      : super(key: key);
  @override
  _TimebankHomePageState createState() => _TimebankHomePageState();
}

class _TimebankHomePageState extends State<TimebankHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
                  onPressed: () {
                    createEditCommunityBloc
                        .updateUserDetails(SevaCore.of(context).loggedInUser);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimebankCreate(
                          timebankId:
                              SevaCore.of(context).loggedInUser.currentTimebank,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            child: getTimebanks(),
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

  Widget getTimebanks() {
    print("length ==> ${widget.selectedCommuntityGroup.timebanks.length}");
    if (widget.selectedCommuntityGroup.timebanks.length <= 1) {
      return NoGroupPlaceHolder();
    }
    return FadeAnimation(
      0,
      Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: ListView.builder(
          itemCount: widget.selectedCommuntityGroup.timebanks.length,
          itemBuilder: (context, index) {
            if (widget.selectedCommuntityGroup.timebanks[index].id !=
                widget.selectedCommuntityGroup.currentCommunity
                    .primary_timebank) {
              return TimeBankCard(
                timebank: widget.selectedCommuntityGroup.timebanks[index],
              );
            }
            return Container();
          },
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 12),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
