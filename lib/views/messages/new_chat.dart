import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';
import 'package:sevaexchange/views/exchange/help.dart';
import 'package:sevaexchange/views/news/newslistview.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/time_bank_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import '../core.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'chatview.dart';

class NewChat extends StatefulWidget {
  //final TabController controller;

  //SearchView(this.controller);

  @override
  NewChatState createState() => NewChatState();
}

class NewChatState extends State<NewChat> with TickerProviderStateMixin {
  //TabController controller;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //controller = widget.controller;
    // controller.addListener(() {
    //   setState(() {});
    // });

    searchTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        // leading: Container(
        //     padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
        //     child: Icon(Icons.search)),
        title: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: TextField(
            style: TextStyle(color: Colors.white),
            controller: searchTextController,
            decoration: InputDecoration(
              hasFloatingPlaceholder: false,
              alignLabelWithHint: true,
              isDense: true,
              // suffix: GestureDetector(
              //   //onTap: () => search(),
              //   child: Icon(Icons.search),
              // ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white)),
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.white),
            ),
            // controller: searchTextController,
          ),
        ),
        // bottom: TabBar(
        //   isScrollable: true,
        //   controller: controller,
        //   tabs: [
        //     Tab(child: Text('Users')),
        //     Tab(child: Text('News')),
        //     Tab(child: Text('Requests')),
        //     Tab(child: Text('Offers')),
        //   ],
        // ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: ResultView(() {}(), searchTextController),
          ),
        ],
      ),
    );
  }
}

class ResultView extends StatefulWidget {
  final SearchType type;
  final TextEditingController controller;

  ResultView(this.type, this.controller);

  @override
  _ResultViewState createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  Widget build(BuildContext context) {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    print('Build view');
    if (widget.controller.text.trim().isEmpty) {
      return Center(child: Text('Enter a User Name'));
    }

    return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUser(queryString: widget.controller.text),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }
        List<UserModel> userList = snapshot.data;

        return ListView.builder(
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                padding: EdgeInsets.only(left: 8, top: 16),
                child: Text('Users', style: sectionTextStyle),
              );
            }
            UserModel user = userList.elementAt(index - 1);
            return Card(
              child: ListTile(
                onTap: user.email == loggedInEmail
                    ? null
                    : () {
                        List users = [user.email, loggedInEmail];
                        users.sort();
                        MessageModel model = MessageModel();
                        model.user1 = users[0];
                        model.user2 = users[1];
                        print(model.user1);
                        print(model.user2);
                        createChat(chat: model).then(
                          (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatView(
                                        useremail: user.email,
                                        messageModel: model,
                                      )),
                            );
                          },
                        );
                      },
                leading: user.photoURL != null
                    ? ClipOval(
                        child: FadeInImage.assetNetwork(
                          fadeInCurve: Curves.easeIn,
                          fadeInDuration: Duration(milliseconds: 400),
                          fadeOutDuration: Duration(milliseconds: 200),
                          width: 50,
                          height: 50,
                          placeholder: 'lib/assets/images/noimagefound.png',
                          image: user.photoURL,
                        ),
                      )
                    : CircleAvatar(),
                title: Text(user.fullname),
                subtitle: Text(user.email),
              ),
            );
          },
          itemCount: userList.length + 1,
        );
      },
    );
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }
}

enum SearchType {
  USER,
//  TIMEBANK,
//  CAMPAIGN,
  NEWS,
  OFFER,
  REQUEST,
}
