import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    //you do not need container here, STACK will do just fine if you'd like to
    //simplify it more
    return Scaffold(
      body: Container(
        child: Stack(children: <Widget>[
          //in the stack, the background is first. using fit:BoxFit.cover will cover
          //the parent container. Use double.infinity for height and width
          FadeInImage(
            placeholder: AssetImage("lib/assets/images/seva-x-logo.png"),
            image: NetworkImage(imageUrl),
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
            //if you use a larger image, you can set where in the image you like most
            //width alignment.centerRight, bottomCenter, topRight, etc...
            alignment: Alignment.center,
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.cancel,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
