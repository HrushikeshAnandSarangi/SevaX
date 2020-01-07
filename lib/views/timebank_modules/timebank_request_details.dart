import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';

class TimeBankRequestDetails extends StatefulWidget {
  final bool applied;

  TimeBankRequestDetails({Key key, this.applied = false}) : super(key: key);

  @override
  _TimeBankRequestDetailsState createState() => _TimeBankRequestDetailsState();
}

class _TimeBankRequestDetailsState extends State<TimeBankRequestDetails> {
  String title = 'Idea to Opportunity FREE Workshop';
  String date = 'Saturday, December 28';
  String timeRange = '10:00 AM - 12:00 PM';
  String location = 'Accel Launchpad';
  String subLocation = '881, 6th Cross Rd, Bengaluru, India';
  String hostedBy = 'Hosted by Indian Startups';

  int totalPeople = 100;
  int peopleApplied = 50;

  String description =
      'India Startup in association with BullerProof. Your Startup is hostion this FREE workshop "Idea to opportunity" at Excel Partner ';

  TextStyle titleStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      ),
                      title: Text(
                        date,
                        style: titleStyle,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        timeRange,
                        style: subTitleStyle,
                        maxLines: 1,
                      ),
                      trailing: Container(
                        height: 30,
                        width: 80,
                        child: widget.applied
                            ? FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Color.fromRGBO(44, 64, 140, 1),
                                child: Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {},
                              )
                            : Container(),
                      ),
                    ),
                    CustomListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      ),
                      title: Text(
                        location,
                        style: titleStyle,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        subLocation,
                        style: subTitleStyle,
                        maxLines: 1,
                      ),
                    ),
                    CustomListTile(
                      // contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      title: Text(
                        hostedBy,
                        style: titleStyle,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '$peopleApplied/$totalPeople people Applied',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: InkWell(
                  onTap: () {
                    print('tapped');
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              CachedNetworkImage(
                imageUrl:
                    'https://technext.github.io/Evento/images/demo/bg-slide-01.jpg',
                fit: BoxFit.fitWidth,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              RequestAppliedNotificationBar(
                isApplied: widget.applied,
                edit: () => print('edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestAppliedNotificationBar extends StatelessWidget {
  final bool isApplied;
  final Function edit;

  const RequestAppliedNotificationBar({
    Key key,
    this.isApplied,
    this.edit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text:
                          'You have ${isApplied ? '' : "not"} applied for the request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isApplied
                        ? TextSpan(
                            text: '\nEdit request',
                            recognizer: TapGestureRecognizer()..onTap = edit,
                          )
                        : TextSpan(),
                  ],
                ),
              ),
            ),
            Container(
              width: 100,
              height: 32,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(0),
                color: Color.fromRGBO(44, 64, 140, 0.7),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 1),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(44, 64, 140, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Text(
                      isApplied ? 'Applied' : 'Apply',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
