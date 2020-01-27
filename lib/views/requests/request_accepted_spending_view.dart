

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/search_manager.dart';

class RequestAcceptedSpendingView extends StatefulWidget {
  @override
  _RequestAcceptedSpendingState createState() => _RequestAcceptedSpendingState();
}

class _RequestAcceptedSpendingState extends State<RequestAcceptedSpendingView> {

  var validitems =[];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Column(
        children: <Widget>[
          getTotalSpending(),
          SizedBox(height: 20,),
          getSpendingResultView(context),

        ],
      ),
    );
   /* return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUserWithTimebankId(
          queryString: "", validItems: validitems),
      builder: (context, snapshot) {
        print('$snapshot');

        //print('find ${snapshot.data}');
        if (snapshot.hasError) {
          Text(snapshot.error.toString());
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
        *//*if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }*//*
        return ListView.builder(
          //itemCount: userList.length + 1,
          itemCount: 10,


          itemBuilder: (context, index) {
            *//*if (index == 0) {
              return Container(
                padding: EdgeInsets.only(left: 8, top: 16),
                child: Text('Users', style: sectionTextStyle),
              );
            }*//*
            // UserModel user = userList.elementAt(index - 1);
            return Column(
              children: <Widget>[
                getTotalSpending(),
                 SizedBox(height: 20,),
                 getSpendingResultView(context),
              ],
            );
          },
        );
      },
    );*/
  }

  Widget getTotalSpending() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Total spendings',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Europa',
            fontWeight: FontWeight.bold
          ),
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Icon(
              Icons.monetization_on,
                size: 40,
                color: Colors.yellow,


              ),
              SizedBox(width: 10,),
              Text('2,591', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
              ),
            ],
          )
        ],
      ),
    );
  }

 Widget getSpendingResultView(BuildContext parentContext) {
        return Container(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      height: 45,
                      width: 45,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'lib/assets/images/profile.png',
                        image: defaultUserImageURL != null
                            ? "https://firebasestorage.googleapis.com/v0/b/sevaexchange.appspot.com/o/timebanklogos%2Fseva_default.jpg?alt=media&token=e3804df4-6146-4bfb-8c8e-b24a62da312d"
                            : defaultUserImageURL,
                      ),
                    ),
                  ),
                  Container(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                              'Umesh Raj',
                              //? 'Not added '
                              //: chatModel.messagTitleUserName,
                          style: Theme.of(parentContext).textTheme.subhead,
                        ),
                        Text(
                          'Dec 11',
                          style: TextStyle(color: Colors.grey, fontFamily: 'Europa'),

                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0,8,5,8),
                        child: Icon(
                          Icons.monetization_on,
                          size: 25,
                          color: Colors.yellow,

                        ),
                      ),

                      Text('100', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
 }
}
