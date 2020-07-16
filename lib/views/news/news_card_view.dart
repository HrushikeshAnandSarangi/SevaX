import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/update_feed.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';

class NewsCardView extends StatefulWidget {
  final NewsModel newsModel;

  NewsCardView({Key key, @required this.newsModel}) : super(key: key);

  @override
  NewsCardViewState createState() {
    // TODO: implement createState
    return NewsCardViewState();
  }
}

class NewsCardViewState extends State<NewsCardView> {
  // assert(newsModel.title != null, 'News title cannot be null');
  // assert(newsModel.description != null, 'News description cannot be null');
  // assert(newsModel.fullName != null, 'Full name cannot be null');
  // final NewsModel newsModel;

  // NewsCardViewState({this.newsModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.newsModel.title == null
              ? widget.newsModel.fullName
              : widget.newsModel.title.trim(),
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        actions: <Widget>[
          widget.newsModel.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                )
              : Offstage(),
          // IconButton(
          //   icon: Icon(Icons.share),
          //   onPressed: () => _shareNews(context),
          // ),
          //shadowing for now as edit feed is not yet completed
          widget.newsModel.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateNewsFeed(
                          newsMmodel: widget.newsModel,
                          timebankId:
                              SevaCore.of(context).loggedInUser.currentTimebank,
                        ),
                      ),
                    );
                  },
                )
              : Offstage()
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              newsAuthorAndDate,
              widget.newsModel.title == null ||
                      widget.newsModel.title == "NoData"
                  ? Offstage()
                  : newsTitle,
              newsImage,
              photoCredits,
              subHeadings,
              document,
              tags,
              listOfHashTags,
              listOfLinks
            ],
          ),
        ),
      ),
    );
  }

  Widget get newsTitle {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
      child:
          widget.newsModel.title == null || widget.newsModel.title == "NoData"
              ? Offstage()
              : Text(
                  widget.newsModel.title.trim(),
                  style: TextStyle(
                      fontSize: 28.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold),
                ),
    );
  }

  Widget get listOfHashTags {
    if (widget.newsModel.hashTags.length > 0) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
<<<<<<< HEAD
            children: widget.newsModel.hashTags.map((hash) {
              // final _random = new Random();
=======
            children: newsModel.hashTags.map((hash) {
              // final _random = Random();
>>>>>>> 372dd456672108f1c7d90dbe7cb62abcbef315c0
              // var element = colorList[_random.nextInt(colorList.length)];
              return chip(hash, false);
            }).toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
    );
  }

  Widget chip(
    String value,
    bool selected,
  ) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white.withAlpha(0),
        child: InkWell(
          customBorder: StadiumBorder(),
          onTap: () {},
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              duration: Duration(milliseconds: 250),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: selected ? Colors.black : null,
              ),
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 250),
                crossFadeState: selected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                secondChild: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get listOfLinks {
    if (widget.newsModel.urlsFromPost.length > 0) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
<<<<<<< HEAD
            children: widget.newsModel.urlsFromPost.map((link) {
              // final _random = new Random();
=======
            children: newsModel.urlsFromPost.map((link) {
              // final _random = Random();
>>>>>>> 372dd456672108f1c7d90dbe7cb62abcbef315c0
              // var element = colorList[_random.nextInt(colorList.length)];
              return chipForLinks(link, false);
            }).toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
    );
  }

  Widget chipForLinks(
    String value,
    bool selected,
  ) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white.withAlpha(0),
        child: InkWell(
          customBorder: StadiumBorder(),
          onTap: () async {
            // print("Here is the value : $value");
            if (await canLaunch(value)) {
              await launch(value);
            } else {
              throw 'Could not launch $value';
            }
          },
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              duration: Duration(milliseconds: 250),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: selected ? Colors.blue : null,
              ),
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 250),
                crossFadeState: selected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Text(value,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis),
                secondChild: Text(value,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get newsAuthorAndDate {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 5, 15),
            height: 40,
            width: 40,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.newsModel.userPhotoURL ?? defaultUserImageURL),
              minRadius: 40.0,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5, left: 5),
                child: Text(
                  widget.newsModel.fullName.trim(),
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  _getFormattedTime(widget.newsModel.postTimestamp),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget get newsImage {
    return widget.newsModel.newsImageUrl == null
        ? Offstage()
        : getImageView(
            url: widget.newsModel.newsImageUrl, imageId: widget.newsModel.id);
  }

  Widget get scrappedImage {
    return widget.newsModel.imageScraped == null ||
            widget.newsModel.imageScraped == "NoData"
        ? Offstage()
        //change tag to avoid hero widget issue
        : getImageView(
            url: widget.newsModel.imageScraped,
            imageId: widget.newsModel.id + "*");
  }

  Widget getImageView({
    String url,
    String imageId,
  }) {
    print("______________________________>" + url);

    return Container(
      margin: EdgeInsets.all(5),
      child: url != null
          ? Hero(
              tag: imageId,
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset('lib/assets/images/noimagefound.png'),
    );
  }

  Widget get photoCredits {
    return widget.newsModel.photoCredits != null &&
            widget.newsModel.photoCredits.isNotEmpty
        ? Center(
            child: Container(
              child: Text(
                widget.newsModel.photoCredits != null
                    ? 'Credits: ${widget.newsModel.photoCredits}'
                    : '',
                style: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        : Offstage();
  }

  Widget get tags {
    return widget.newsModel.description == null
        ? Offstage()
        : Container(
            padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.newsModel.description.trim(),
                  style: TextStyle(fontSize: 18.0, height: 1.4),
                )
              ],
            ),
          );
  }

  Widget get document {
    return Container(
      child: widget.newsModel.newsDocumentUrl == null ||
              widget.newsModel.newsDocumentUrl == ''
          ? Offstage()
          : GestureDetector(
              onTap: () => openPdfViewer(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.grey[100],
                  child: ListTile(
                    leading: Icon(Icons.attachment),
                    title: Text(
                      widget.newsModel.newsDocumentName ?? "Document.pdf",
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<File> createFileOfPdfUrl(String documentUrl) async {
    final url = documentUrl;
    final filename = widget.newsModel.newsDocumentName;
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void openPdfViewer() {
    createFileOfPdfUrl(widget.newsModel.newsDocumentUrl).then((f) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  docName: widget.newsModel.newsDocumentName,
                  pathPDF: f.path,
                  pdf: f,
                )),
      );
    });
  }

  Widget get subHeadings {
    return widget.newsModel.subheading == null
        ? Offstage()
        : Container(
            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.newsModel.subheading.trim(),
                  style: TextStyle(fontSize: 18.0, height: 1.4),
                ),
                Center(
                  child: scrappedImage,
                ),
              ],
            ),
          );
  }

  BuildContext dialogContext;
  void showProgressDialog(String message, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  void _showDeleteConfirmationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (_context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context).translate('chat', 'delete_feed')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context)
                  .translate('chat', 'are_you_sure_feed')),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('chat', 'delete_button'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(_context);
                      showProgressDialog(
                          AppLocalizations.of(context)
                              .translate('chat', 'delete_feed_progress'),
                          parentContext);
                      _deleteNews(parentContext);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'cancel'),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () => Navigator.pop(_context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFormattedTime(int timestamp) {
    return timeAgo.format(DateTime.fromMillisecondsSinceEpoch(timestamp),
        locale:
            Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
  }

  void _deleteNews(BuildContext context) async {
    await deleteNews(widget.newsModel);
    if (dialogContext != null) {
      Navigator.pop(dialogContext);
    }
    Navigator.of(context).pop();

    // Navigator.pop(context);
  }
}
