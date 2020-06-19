import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_new_chat_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/group_members_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/timebank_members_page.dart';
import 'package:sevaexchange/ui/screens/message/widgets/frequent_contacts_builder.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class NewChatPage extends StatefulWidget {
  final List<FrequentContactsModel> frequentContacts;

  const NewChatPage({Key key, this.frequentContacts}) : super(key: key);
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _bloc.isSelectionEnabled
                ? SelectedMemberListBuilder()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute<ChatModel>(
                            builder: (context) => CreateNewChatPage(
                              frequentContacts: widget.frequentContacts,
                              isSelectionEnabled: true,
                            ),
                          ),
                        )
                            .then((ChatModel model) {
                          if (model != null) {
                            Navigator.of(context).pop(model);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  chatModel: model,
                                  senderId: model.groupDetails.admins[0],
                                ),
                              ),
                            );
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(groupIcon),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Multi-User Messaging",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            Container(
              height: 30,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[300],
              padding: EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                "FREQUENTLY CONTACTED",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            widget.frequentContacts.length > 0
                ? FrequentContactsBuilder(
                    widget.frequentContacts,
                    _bloc.isSelectionEnabled,
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("No Frequent Contacts"),
                    ),
                  ),
            StreamBuilder<List<TimebankModel>>(
              stream: _bloc.timebanksOfUser,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                print(snapshot.data.length);
                if (snapshot.data.length == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey[300],
                        padding: EdgeInsets.only(left: 12),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "TIMEBANK MEMBERS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TimebankMembersPage(),
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: <Widget>[
                        tabBuilder("GROUPS", 0),
                        tabBuilder("TIMEBANK MEMBERS", 1),
                      ],
                    ),
                    [GroupMembersPage(), TimebankMembersPage()][currentIndex],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget tabBuilder(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index != currentIndex) {
            setState(() {
              currentIndex = index;
            });
          }
        },
        child: Container(
          height: 30,
          alignment: Alignment.center,
          color: index == currentIndex
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: index == currentIndex ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
