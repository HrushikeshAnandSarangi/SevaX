import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaperList extends StatelessWidget {
  // Declare a field that holds the Todo
  final reqs;
  final destination;

  // In the constructor, require a Todo
  PaperList({Key key, @required this.reqs, this.destination}) : super(key: key);

  String _getPostitColor(context) {
    final _random = new Random();
    int next(int min, int max) => min + _random.nextInt(max - min);

    switch (next(1, 4)) {
      case 1:
        context.data['color'] = Color.fromRGBO(237, 230, 110, 1.0);
        return 'lib/assets/images/yellow.png';
        break;
      case 2:
        context.data['color'] = Color.fromRGBO(170, 204, 105, 1.0);
        return 'lib/assets/images/green.png';
        break;
      case 3:
        context.data['color'] = Color.fromRGBO(112, 198, 233, 1.0);
        return 'lib/assets/images/blue.png';
        break;
      case 4:
        context.data['color'] = Color.fromRGBO(213, 106, 162, 1.0);
        return 'lib/assets/images/pink.png';
        break;
      case 5:
        context.data['color'] = Color.fromRGBO(160, 107, 166, 1.0);
        return 'lib/assets/images/violet.png';
        break;
      default:
        context.data['color'] = Color.fromRGBO(237, 230, 110, 1.0);
        return 'lib/assets/images/yellow.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: ListView(
        children: reqs.map((DocumentSnapshot document) {
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(_getPostitColor(document)))),
              padding: EdgeInsets.only(
                  top: 5.0, bottom: 5.0, left: 30.0, right: 15.0),
              child: Card(
                  elevation: 0,
                  color: Color.fromRGBO(255, 255, 153, 0.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 10.0),
                    // isThreeLine: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              destination(offerModel: document),
                        ),
                      );
                    },
                    // leading: Image.network(
                    //   'https://github.com/flutter/website/blob/master/src/_includes/code/layout/lakes/images/lake.jpg?raw=true', width: 70.0,
                    //   ),
                    title: Text(
                      document['title'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(document['fullname']),
                  )));
        }).toList(),
      ),
    );
  }
}
