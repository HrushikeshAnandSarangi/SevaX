import 'dart:convert';

// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/MembersInvolved.dart';

import '../../flavor_config.dart';

class RequestStatusView extends StatefulWidget {
  final String requestId;

  RequestStatusView({@required this.requestId});

  @override
  State<StatefulWidget> createState() {
    return RequestStatusViewState();
  }
}

class RequestStatusViewState extends State<RequestStatusView> {
  Future<List<MemberForRequest>> membersInRequest;
  bool isSent = false;

  @override
  void initState() {
    super.initState();
    membersInRequest = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            S.of(context).approved_member,
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          actions: <Widget>[],
        ),
        floatingActionButton: FloatingActionButton.extended(
            label: Text(S.of(context).send_csv_file),
            foregroundColor: FlavorConfig.values.buttonTextColor,
            onPressed: () async {
              await sendMail(context);
              showDialog(
                context: context,
                builder: (BuildContext viewcontext) {
                  // return object of type Dialog
                  return AlertDialog(
                    title: Text(this.isSent == true
                        ? S.of(context).success
                        : S.of(context).failure),
                    content: Text(this.isSent == true
                        ? "CSV file sent successfully to ${SevaCore.of(context).loggedInUser.email}."
                        : S.of(context).general_stream_error),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      FlatButton(
                        child: Text(S.of(context).ok.toUpperCase()),
                        onPressed: () {
                          Navigator.of(viewcontext).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }),
        body: Center(
            child: FutureBuilder<List<MemberForRequest>>(
          future: membersInRequest,
          builder: (builderContext, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  ...snapshot.data.map((member) {
                    return getUserWidget(member, builderContext);
                  }).toList()
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error ${snapshot.error}');
            }
            // By default, show a loading spinner.
            return LoadingIndicator();
          },
        )));
  }

  Widget getUserWidget(MemberForRequest userSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => (ProfileViewer(
              userEmail: userSelected.email,
            )),
          ),
        );
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(userSelected.photourl ?? defaultUserImageURL),
          ),
          title: Text(
            userSelected.fullname,
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            userSelected.email,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  final imgUrl = "https://unsplash.com/photos/iEJVyyevw-U/download?force=true";
  bool downloading = false;
  var progressString = "";

//  Future<void> downloadFile() async {
//    Dio dio = Dio();
//
//    try {
//      Directory dir = await getex();
//      //await dio.download(imgUrl, "${widget.requestId}.csv",);
//
//      await dio.download(imgUrl, "${dir.path}/myimage.jpg",
//          onReceiveProgress: (rec, total) {
//            print("Rec: $rec , Total: $total");
//
//            setState(() {
//              downloading = true;
//              progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
//            });
//          });
//    } catch (e) {
//      print(e);
//    }
//

//  oia9gs
//    setState(() {
//      downloading = false;
//      progressString = "Completed";
//    });
//    print("Download completed");
//  }

//  void downloadFile() {
//    HttpClient().getUrl(Uri.parse('https://us-central1-sevaexchange.cloudfunctions.net/requests_members?requestId=${widget.requestId}&receiver=${SevaCore.of(context).loggedInUser.email}'))
//        .then((HttpClientRequest request) => request.close())
//        .then((HttpClientResponse response)  {
//          print(response);
//      response.pipe(new File('${widget.requestId}.csv').openWrite());
//    });
//        //print(response);
//  }

  Future sendMail(BuildContext context) async {
    final response1 = await http.get(
        '${FlavorConfig.values.cloudFunctionBaseURL}/requests_membersSevax?requestId=${widget.requestId}&receiver=${SevaCore.of(context).loggedInUser.email}');

    if (response1.statusCode == 200) {
      this.isSent = true;
    } else {
      this.isSent = false;
      throw Exception('Failed to load post');
    }
  }

  Future<List<MemberForRequest>> fetchPost() async {
    final response = await http.post(
        '${FlavorConfig.values.cloudFunctionBaseURL}/getApprovedMembers',
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"requestId": widget.requestId}));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => MemberForRequest.fromJson(m)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
