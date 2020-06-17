import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/widgets/camera_icon.dart';

class CreateGroupPage extends StatelessWidget {
  final CreateChatBloc bloc;
  const CreateGroupPage({Key key, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          "New Multi-User Messaging",
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Create",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: CameraIcon(radius: 35),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(),
                      TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Multi-User Messaging Name",
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Divider(),
                      Text(
                        "Please provide a multi-user messaging \nsubject and optional group icon.",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            StreamBuilder<List<String>>(
                stream: bloc.selectedMembers,
                builder: (context, snapshot) {
                  return Container(
                    height: 30,
                    width: double.infinity,
                    color: Colors.grey[300],
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "PARTICIPANTS: ${snapshot.data?.length ?? 0} OF 256",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SelectedMemberWrapBuilder(bloc: bloc),
            ),
          ],
        ),
      ),
    );
  }
}
