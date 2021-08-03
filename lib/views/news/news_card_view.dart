import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/services/news/news_service.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/update_feed.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
import '../../labels.dart';

class NewsCardView extends StatefulWidget {
  final NewsModel newsModel;
  final TimebankModel timebankModel;
  final bool isFocused;
  CommunityModel communityModel;

  NewsCardView(
      {Key key,
      @required this.newsModel,
      this.isFocused = false,
      this.timebankModel,
      this.communityModel})
      : super(key: key);

  @override
  NewsCardViewState createState() {
    return NewsCardViewState();
  }
}

class NewsCardViewState extends State<NewsCardView> {
  TextEditingController _textEditingController = TextEditingController();
  bool isShowSticker;
  final profanityDetector = ProfanityDetector();
  TimebankModel timebankModel = TimebankModel({});

  bool isProfane = false;
  String errorText = '';
  @override
  void initState() {
    super.initState();
    isShowSticker = false;
    if (widget.timebankModel == null) {
      getTimebank();
    }
    if (this.widget.isFocused) {
      setState(() {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  Future<void> getTimebank() async {
    timebankModel = await FirestoreManager.getTimeBankForId(
        timebankId: widget.newsModel.entity.entityId);
    setState(() {});
  }

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
          widget.timebankModel != null &&
                  utils.isDeletable(
                      timebankCreatorId: widget.timebankModel.creatorId,
                      context: context,
                      contentCreatorId: widget.newsModel.sevaUserId,
                      communityCreatorId: widget
                              .timebankModel.managedCreatorIds.isNotEmpty
                          ? widget.timebankModel.managedCreatorIds.elementAt(0)
                          : BlocProvider.of<HomeDashBoardBloc>(context)
                                  ?.selectedCommunityModel
                                  ?.created_by ??
                              widget.communityModel.created_by)
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
        child: Column(children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
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
                  listOfLinks,
                  LikeComment(
                    newsModel: widget.newsModel,
                    userId: SevaCore.of(context).loggedInUser.email,
                    isFromHome: false,
                    timebankModel: widget.timebankModel,
                  ),

                  //============================//
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 19, 8, 0),
                    child: StreamBuilder<NewsModel>(
                      stream: NewsService()
                          .getCommentsByFeedId(id: widget.newsModel.id),
                      builder: (context, snapshot) {
                        if (snapshot.data == null ||
                            (snapshot.hasData &&
                                snapshot.data.comments.length == 0)) {
                          return Center(
                            child: Text(S.of(context).no_data),
                          );
                        }
                        if (snapshot.hasData) {
                          List<Comments> commentsList = snapshot.data.comments;
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: commentsList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onLongPress: () async {
                                  if (commentsList[index].createdEmail ==
                                      SevaCore.of(context).loggedInUser.email) {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (_) => DeleteCommentOverlay(
                                        feed: widget.newsModel,
                                        index: index,
                                        isReply: false,
                                      ),
                                    );
                                    return result;
                                  }
                                },
                                child: Container(
                                  child: CommentContainer(
                                      commentsList[index], index),
                                ),
                              );
                            },
                            shrinkWrap: true,
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(
            color: Colors.black38,
            height: 1,
            indent: 0,
          ),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 3.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 3.0, top: 3.0, right: 8.0, bottom: 3.0),
                          child: CircleAvatar(
                              backgroundImage: NetworkImage(
                            SevaCore.of(context).loggedInUser.photoURL ??
                                defaultUserImageURL,
                          )),
                        ),
                        labelText: S.of(context).add_comment,
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(3.0),
                      ),
                      autofocus: this.widget.isFocused ? true : false,
                      onTap: () => {
                        setState(() {
                          isShowSticker = false;
                        }),
                      },
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Image.asset(
                        "lib/assets/images/send.png",
                        height: 20,
                        width: 20,
                      ),
                    ),
                    onTap: () async {
                      if (_textEditingController.text != "") {
                        if (profanityDetector
                            .isProfaneString(_textEditingController.text)) {
                          setState(() {
                            isProfane = true;
                            errorText = S.of(context).profanity_text_alert;
                          });
                        } else {
                          setState(() {
                            isProfane = false;
                            errorText = '';
                          });
                          _saveComment(Comments(
                              feedId: widget.newsModel.id,
                              userPhotoURL:
                                  SevaCore.of(context).loggedInUser.photoURL,
                              fullName: SevaCore.of(context)
                                          .loggedInUser
                                          .fullname !=
                                      null
                                  ? SevaCore.of(context).loggedInUser.fullname
                                  : S.of(context).anonymous_user,
                              createdEmail:
                                  SevaCore.of(context).loggedInUser.email,
                              createdAt: DateTime.now().millisecondsSinceEpoch,
                              comment: _textEditingController.text));
                          _textEditingController.clear();
                        }
                      }
                    },
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.sentiment_satisfied,
                      ),
                      iconSize: 30,
                      onPressed: () => {
                            setState(() {
                              isShowSticker = !isShowSticker;
                              if (isShowSticker) {
                                FocusScope.of(context).unfocus();
                              } else {
                                isShowSticker = false;
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                            }),
                          }),
                ],
              ),
            ),
          ),
          isProfane
              ? Container(
                  margin: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorText,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                )
              : Offstage(),
          (isShowSticker ? buildSticker() : Container())
//          Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
//              Widget>[
//          ]),
        ]),
      ),
    );
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        _textEditingController.text += emoji.emoji;
      },
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

  _saveComment(Comments comment) {
    setState(() {
      widget.newsModel.comments.add(comment);
      NewsService().updateFeedById(newsModel: widget.newsModel);
    });
  }

  Widget get listOfHashTags {
    if (widget.newsModel.hashTags.isNotEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widget.newsModel.hashTags.map((hash) {
              // final _random = new Random();
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
            children: widget.newsModel.urlsFromPost.map((link) {
              // final _random = new Random();
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
              throw S.of(context).could_not_launch + '$value';
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
          UserProfileImage(
            timebankModel: widget.timebankModel,
            width: 40,
            height: 40,
            userId: widget.newsModel.sevaUserId,
            email: widget.newsModel.email,
            photoUrl: widget.newsModel.userPhotoURL,
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
    return Container(
      margin: EdgeInsets.all(5),
      child: url != null
          ? Hero(
              tag: imageId,
              child: Image.network(
                url ?? defaultUserImageURL,
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
                    ? S.of(context).credits + '${widget.newsModel.photoCredits}'
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
                      widget.newsModel.newsDocumentName ??
                          S.of(context).doc_pdf,
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void openPdfViewer() {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.show();
    createFileOfPdfUrl(
            widget.newsModel.newsDocumentUrl, widget.newsModel.newsDocumentName)
        .then((f) {
      progressDialog.hide();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  docName: widget.newsModel.newsDocumentName,
                  pathPDF: f.path,
                  isFromFeeds: true,
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
          title: Text(S.of(context).delete_feed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(S.of(context).delete_feed_confirmation),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  CustomElevatedButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      S.of(context).delete,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(_context);
                      showProgressDialog(
                          S.of(context).deleting_feed, parentContext);
                      _deleteNews(parentContext);
                    },
                  ),
                  CustomTextButton(
                    child: Text(
                      S.of(context).cancel,
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
        locale: Locale(getLangTag()).toLanguageTag());
  }

  void _deleteNews(BuildContext context) async {
    await deleteNews(widget.newsModel);
    if (dialogContext != null) {
      Navigator.pop(dialogContext);
    }
    Navigator.of(context).pop();

    // Navigator.pop(context);
  }

  Widget CommentContainer(Comments commentsList, index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserProfileImage(
            photoUrl: commentsList.userPhotoURL,
            email: widget.newsModel.email,
            userId: widget.newsModel.sevaUserId,
            height: 30,
            width: 30,
            timebankModel: widget.timebankModel,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text('${commentsList.fullName}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 0),
                  child: Text(
                      timeAgo.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              commentsList.createdAt),
                          locale: Locale(getLangTag()).toLanguageTag()),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 0, 0, 0.5))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${commentsList.comment}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        InkWell(
                          onTap: () {
                            Set<String> likesList =
                                Set.from(commentsList.likes);
                            commentsList.likes != null &&
                                    commentsList.likes
                                        .contains(commentsList.createdEmail)
                                ? likesList.remove(commentsList.createdEmail)
                                : likesList.add(commentsList.createdEmail);
                            // commentsList.likes = likesList.toList();
                            widget.newsModel.comments[index].likes =
                                likesList.toList();
                            NewsService()
                                .updateFeed(newsModel: widget.newsModel);
                            setState(() {});
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: commentsList.likes != null &&
                                    commentsList.likes
                                        .contains(commentsList.createdEmail)
                                ? Icon(
                                    Icons.favorite,
                                    color: Color(0xFFec444b),
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('${commentsList.likes.length}',
                                // child: Text('1',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 0, 0, 0.5))))),
                    Padding(
                        padding: EdgeInsets.only(left: 2, top: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(S.of(context).likes,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                )))),
                    Padding(
                        padding: EdgeInsets.only(left: 12, top: 0),
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RepliesView(
                                      commentsList,
                                      widget.newsModel,
                                      index,
                                      widget.timebankModel)));
                            },
                            child: Text(S.of(context).reply,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                )))),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      if (commentsList.comments.length > 0) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RepliesView(
                                commentsList,
                                widget.newsModel,
                                index,
                                widget.timebankModel)));
                      }
                    },
                    child: Text(
                        commentsList.comments.length > 0
                            ? S.of(context).view_prev_replies
                            : '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        )),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DetailDescription extends StatefulWidget {
  NewsModel data = NewsModel();
  TimebankModel timebankModel;
  UserModel userModel = UserModel();
  List<String> moreList = [];
  String userId;
  final bool isFocused;
  DetailDescription(this.data,
      {this.isFocused = false, this.userModel, this.timebankModel});
  @override
  _DetailDescriptionState createState() => _DetailDescriptionState();
}

class _DetailDescriptionState extends State<DetailDescription> {
  NewsModel data = NewsModel();
  bool isFocused;
  _DetailDescriptionState();
  TextEditingController _textEditingController = TextEditingController();
  // List<Comments> comments = List<Comments>();
  final dbRef = CollectionRef;
  bool isShowSticker;

  @override
  void initState() {
    super.initState();
    isShowSticker = false;
    if (isFocused) {
      setState(() {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  _saveComment(Comments comment) {
    setState(() {
      data.comments.add(comment);
      NewsService().updateFeedById(newsModel: data);
    });
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        _textEditingController.text += emoji.emoji;
      },
    );
  }

  void updateMoreList() {
    widget.moreList.clear();
//    widget.userModel.bookmarks.contains(data.id) == true
//        ? widget.moreList.add('UnBookmark')
//        : widget.moreList.add('Bookmark');
//    widget.userModel.following.contains(data.createdUserId) == true
//        ? widget.moreList.add('Unfollow')
//        : widget.moreList.add('Follow');
  }

  Future<bool> _onBackPressed() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = (!isShowSticker);
      });
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Navigator.pop(context, false),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          titleSpacing: 0.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: Image.network('${data.userPhotoURL}'),
                  )),
              Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data.fullName}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Europa',
                          color: Colors.black,
                          letterSpacing: 0,
                          fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.only(bottom: 100.0),
          child: FloatingActionButton(
              child: Icon(Icons.share),
              backgroundColor: Colors.black,
              onPressed: () {
//                Share.share("Testing");
              }),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 19, 12, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 20, bottom: 12),
                            child: HashTagText(
                              text: data.description,
                              textStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Europa',
                                letterSpacing: 0,
                                height: 2,
                                fontSize: 12,
                                color: Color.fromRGBO(34, 40, 49, 1),
                              ),
                              hashTagStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Europa',
                                letterSpacing: 0,
                                height: 2,
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                              onTap: (_) {},
                            )),
                        Container(
                          // padding: EdgeInsets.only(),
                          child: Divider(),
                        ),
                        LikeComment(
                          newsModel: data,
                          isFromHome: false,
                          userId: SevaCore.of(context).loggedInUser.email,
                          timebankModel: widget.timebankModel,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.width / 0.9,
                          padding: EdgeInsets.fromLTRB(0, 19, 0, 0),
                          child: StreamBuilder<NewsModel>(
                              stream: NewsService()
                                  .getCommentsByFeedId(id: data.id),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Center(
                                    child: Text(S.of(context).no_data),
                                  );
                                }
                                if (snapshot.hasData) {
                                  List<Comments> commentsList =
                                      snapshot.data.comments;
                                  return ListView.builder(
                                    itemCount: commentsList.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onLongPress: () async {
                                          if (commentsList[index]
                                                  .createdEmail ==
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .email) {
                                            final result = await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  DeleteCommentOverlay(
                                                feed: data,
                                                index: index,
                                                isReply: false,
                                              ),
                                            );
                                            return result;
                                          }
                                        },
                                        child: Container(
                                          child: CommentContainer(
                                              commentsList[index], index),
                                        ),
                                      );
                                    },
                                    shrinkWrap: true,
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                  left: 3.0, top: 3.0, right: 8.0, bottom: 3.0),
                              child: CircleAvatar(
                                child: ClipOval(
                                  child: widget.userModel.photoURL == null
                                      ? Container(color: Colors.grey)
                                      : Image.network(
                                          widget.userModel.photoURL,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            labelText: S.of(context).add_comment,
                            isDense: true,
                            contentPadding: EdgeInsets.all(3.0),
                          ),
                          autofocus: isFocused ? true : false,
                          onTap: () => {
                            setState(() {
                              isShowSticker = false;
                            }),
                          },
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Image.asset(
                            "lib/assets/images/send.png",
                            height: 20,
                            width: 20,
                          ),
                        ),
                        onTap: () async {
                          if (_textEditingController.text != "") {
                            _saveComment(Comments(
                                feedId: data.id,
                                userPhotoURL:
                                    SevaCore.of(context).loggedInUser.photoURL,
                                fullName: SevaCore.of(context)
                                            .loggedInUser
                                            .fullname !=
                                        null
                                    ? SevaCore.of(context).loggedInUser.fullname
                                    : S.of(context).anonymous_user,
                                createdEmail:
                                    SevaCore.of(context).loggedInUser.email,
                                createdAt:
                                    DateTime.now().millisecondsSinceEpoch,
                                comment: _textEditingController.text));
                            _textEditingController.clear();
                          }
                        },
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.sentiment_satisfied,
                          ),
                          iconSize: 30,
                          onPressed: () => {
                                setState(() {
                                  isShowSticker = !isShowSticker;
                                  if (isShowSticker) {
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    isShowSticker = false;
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  }
                                }),
                              }),
                    ],
                  ),
                ),
              ),
              (isShowSticker ? buildSticker() : Container()),
            ],
          ),
        ),
      ),
    );
  }

  Widget CommentContainer(Comments commentsList, index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            child: ClipOval(
              child: widget.userModel.photoURL == null
                  ? Container(color: Colors.grey)
                  : Image.network(
                      widget.data.userPhotoURL ?? defaultUserImageURL,
                      fit: BoxFit.cover,
                    ),
            ),
            radius: 25,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text('${commentsList.fullName}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 0),
                  child: Text(
                      timeAgo.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              commentsList.createdAt),
                          locale: Locale(getLangTag()).toLanguageTag()),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 0, 0, 0.5))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${commentsList.comment}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        InkWell(
                          onTap: () {
                            Set<String> likesList =
                                Set.from(commentsList.likes);
                            commentsList.likes != null &&
                                    commentsList.likes
                                        .contains(commentsList.createdEmail)
                                ? likesList.remove(commentsList.createdEmail)
                                : likesList.add(commentsList.createdEmail);
                            // commentsList.likes = likesList.toList();
                            data.comments[index].likes = likesList.toList();
                            NewsService().updateFeed(newsModel: data);
                            setState(() {});
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: commentsList.likes != null &&
                                    commentsList.likes
                                        .contains(commentsList.createdEmail)
                                ? Icon(
                                    Icons.favorite,
                                    color: Color(0xFFec444b),
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('${commentsList.likes.length}',
                                // child: Text('1',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 0, 0, 0.5))))),
                    Padding(
                        padding: EdgeInsets.only(left: 2, top: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(S.of(context).likes,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                )))),
                    Padding(
                        padding: EdgeInsets.only(left: 12, top: 0),
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RepliesView(
                                      commentsList,
                                      data,
                                      index,
                                      widget.timebankModel)));
                            },
                            child: Text(S.of(context).reply,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                )))),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      if (commentsList.comments.length > 0) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RepliesView(commentsList,
                                data, index, widget.timebankModel)));
                      }
                    },
                    child: Text(
                        commentsList.comments.length > 0
                            ? S.of(context).view_prev_replies
                            : '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        )),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class HashTagText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final TextStyle hashTagStyle;
  final Function(String) onTap;

  const HashTagText({
    Key key,
    this.text,
    this.textStyle,
    this.hashTagStyle,
    @required this.onTap,
  })  : assert(onTap != null),
        assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _getHashTagTextSpan(
        hashTagStyle ?? TextStyle(color: Colors.blue),
        textStyle ?? TextStyle(color: Colors.black),
        text,
        onTap,
      ),
    );
  }

  TextSpan _getHashTagTextSpan(
    TextStyle decoratedStyle,
    TextStyle basicStyle,
    String source,
    Function(String) onTap,
  ) {
    final _annotations =
        _Annotator(decoratedStyle: decoratedStyle, textStyle: basicStyle)
            .getAnnotations(source);
    if (_annotations.isEmpty) {
      return TextSpan(text: source, style: basicStyle);
    } else {
      _annotations.sort();
      final span = _annotations
          .asMap()
          .map(
            (index, item) {
              return MapEntry(
                index,
                TextSpan(
                  style: item.style,
                  text: item.range.textInside(source),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      final _annotation = _annotations[index];
                      if (_annotation.style == decoratedStyle) {
                        onTap(_annotation.range.textInside(source));
                      }
                    },
                ),
              );
            },
          )
          .values
          .toList();
      return TextSpan(children: span);
    }
  }
}

class _Annotation extends Comparable<_Annotation> {
  _Annotation({@required this.range, this.style});

  final TextRange range;
  final TextStyle style;

  @override
  int compareTo(_Annotation other) {
    return range.start.compareTo(other.range.start);
  }
}

class _Annotator {
  final TextStyle textStyle;
  final TextStyle decoratedStyle;
  static final hashTagRegExp = RegExp(
    r'\B(\#[a-zA-Z]+\b)(?!;)',
    multiLine: true,
  );

  _Annotator({this.textStyle, this.decoratedStyle});

  List<_Annotation> _getSourceAnnotations(
      List<RegExpMatch> tags, String copiedText) {
    TextRange previousItem;
    final result = [];
    for (var tag in tags) {
      if (previousItem == null) {
        if (tag.start > 0) {
          result.add(
            _Annotation(
              range: TextRange(start: 0, end: tag.start),
              style: textStyle,
            ),
          );
        }
      } else {
        result.add(
          _Annotation(
            range: TextRange(start: previousItem.end, end: tag.start),
            style: textStyle,
          ),
        );
      }

      result.add(
        _Annotation(
          range: TextRange(start: tag.start, end: tag.end),
          style: decoratedStyle,
        ),
      );
      previousItem = TextRange(start: tag.start, end: tag.end);
    }

    if (result.last.range.end < copiedText.length) {
      result.add(_Annotation(
          range:
              TextRange(start: result.last.range.end, end: copiedText.length),
          style: textStyle));
    }
    return result;
  }

  List<_Annotation> getAnnotations(String copiedText) {
    final tags = hashTagRegExp.allMatches(copiedText).toList();
    if (tags.isEmpty) {
      return [];
    }
    final sourceAnnotations = _getSourceAnnotations(tags, copiedText);
    return sourceAnnotations;
  }
}

class LikeComment extends StatefulWidget {
  final NewsModel newsModel;
  final TimebankModel timebankModel;
  final bool isFromHome;
  final String userId;
  LikeComment(
      {this.newsModel, this.isFromHome, this.userId, this.timebankModel});
  @override
  _LikeCommentState createState() => _LikeCommentState();
}

class _LikeCommentState extends State<LikeComment> {
  _LikeCommentState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10),
        child: InkWell(
          onTap: () {
            Set<String> likesList = Set.from(widget.newsModel.likes);
            widget.newsModel.likes != null &&
                    widget.newsModel.likes.contains(widget.userId)
                ? likesList.remove(widget.userId)
                : likesList.add(widget.userId);
            widget.newsModel.likes = likesList.toList();
            NewsService().updateFeed(newsModel: widget.newsModel);
            setState(() {});
          },
          child: Align(
            alignment: Alignment.bottomCenter,
            child: widget.newsModel.likes != null &&
                    widget.newsModel.likes.contains(widget.userId)
                ? Icon(
                    Icons.favorite,
                    color: Color(0xFFec444b),
                  )
                : Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.grey,
                  ),
          ),
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 6, top: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${widget.newsModel.likes.length.toString()}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)))),
      Padding(
          padding: EdgeInsets.only(left: 3, top: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(S.of(context).likes,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  )))),
      Padding(
          padding: EdgeInsets.only(left: 20, top: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${widget.newsModel.comments.length}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)))),
      GestureDetector(
        onTap: () {
          widget.isFromHome
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailDescription(
                            widget.newsModel,
                            isFocused: true,
                            timebankModel: widget.timebankModel,
                          )))
              : null;
        },
        child: Padding(
            padding: EdgeInsets.only(left: 3, top: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(S.of(context).comments,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    )))),
      ),
      Flexible(fit: FlexFit.tight, child: SizedBox()),
    ]);
  }
}

class DeleteCommentOverlay extends StatefulWidget {
  int comments;
  NewsModel feed;
  int index;
  bool isReply;

  DeleteCommentOverlay({this.feed, this.comments, this.index, this.isReply});

  @override
  State<StatefulWidget> createState() => DeleteCommentOverlayState();
}

class DeleteCommentOverlayState extends State<DeleteCommentOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  _deleteReplyComment(int comment) {
    setState(() {
      widget.feed.comments[widget.index].comments.removeAt(comment);
      NewsService().updateFeedById(newsModel: widget.feed);
    });
  }

  _deleteComment(int index) {
    setState(() {
      widget.feed.comments.removeAt(index);
//      print(widget.feed.comments[widget.index].comments.length);
      NewsService().updateFeedById(newsModel: widget.feed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(15.0),
              height: 180.0,
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 20.0, right: 20.0),
                    child: Text(
                      S.of(context).delete_comment_msg,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  )),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ButtonTheme(
                            height: 35.0,
                            minWidth: 110.0,
                            child: CustomElevatedButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Text(
                                S.of(context).delete,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (widget.isReply) {
                                    _deleteReplyComment(widget.comments);
                                  } else {
                                    _deleteComment(widget.index);
                                  }
                                  Navigator.pop(context);
                                });
                              },
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: ButtonTheme(
                              height: 35.0,
                              minWidth: 110.0,
                              child: CustomElevatedButton(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Text(
                                  S.of(context).cancel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                              ))),
                    ],
                  ))
                ],
              )),
        ),
      ),
    );
  }
}

class RepliesView extends StatefulWidget {
  Comments comment;
  NewsModel feed;
  TimebankModel timebankModel;
  int index;

  RepliesView(this.comment, this.feed, this.index, this.timebankModel);

  @override
  _RepliesViewState createState() => _RepliesViewState();
}

class _RepliesViewState extends State<RepliesView> {
  TextEditingController _textEditingController = TextEditingController();
  bool isFocused = true;
  bool isShowSticker;
  bool isKeyboardVisible;
  final profanityDetector = ProfanityDetector();
  bool isProfane = false;
  String errorText = '';
  @override
  void initState() {
    super.initState();
    isShowSticker = false;
    isKeyboardVisible = false;

    if (isFocused) {
      setState(() {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  _saveComment(Comments comment) {
    setState(() {
      if (widget.feed.comments[widget.index].comments == null) {
        widget.feed.comments[widget.index].comments = [];
      }
      widget.feed.comments[widget.index].comments.add(comment);
      NewsService().updateFeedById(newsModel: widget.feed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          S.of(context).replies,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Container(
                      child: CommentContainer(
                          widget.comment, 25, 100, true, widget.index)),
                  Container(
                    height: MediaQuery.of(context).size.width / 0.9,
                    padding: EdgeInsets.only(left: 50),
                    child: StreamBuilder<NewsModel>(
                        stream: NewsService()
                            .getCommentsByFeedId(id: widget.feed.id),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(
                              child: Text(S.of(context).no_data),
                            );
                          }
                          if (snapshot.hasData) {
                            List<Comments> commentsList =
                                snapshot.data.comments[widget.index].comments;
                            return ListView.builder(
                              itemCount: commentsList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onLongPress: () async {
                                    if (commentsList[index].createdEmail ==
                                        await PreferenceManager
                                            .loggedInUserId) {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (_) => DeleteCommentOverlay(
                                            feed: widget.feed,
                                            comments: index,
                                            index: widget.index,
                                            isReply: true),
                                      );
                                      return result;
                                    }
                                  },
                                  child: Container(
                                    child: CommentContainer(commentsList[index],
                                        20, 150, false, index),
                                  ),
                                );
                              },
                              shrinkWrap: true,
                            );
                          }
                        }),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.black38,
              height: 1,
              indent: 0,
            ),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 3.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                left: 3.0, top: 3.0, right: 8.0, bottom: 3.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  SevaCore.of(context).loggedInUser.photoURL ??
                                      defaultUserImageURL),
                            ),
                          ),
                          labelText: S.of(context).add_comment,
                          isDense: true,
                          contentPadding: EdgeInsets.all(3.0),
                        ),
                        autofocus: isFocused ? true : false,
                        onTap: () => {
                          setState(() {
                            isShowSticker = false;
                          }),
                        },
                      ),
                    ),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Image.asset(
                          "lib/assets/images/send.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      onTap: () async {
                        if (_textEditingController.text != "") {
                          if (profanityDetector
                              .isProfaneString(_textEditingController.text)) {
                            setState(() {
                              isProfane = true;
                              errorText = S.of(context).profanity_text_alert;
                            });
                          } else {
                            setState(() {
                              isProfane = false;
                              errorText = '';
                            });

                            _saveComment(Comments(
                                feedId: widget.feed.id,
                                userPhotoURL:
                                    SevaCore.of(context).loggedInUser.photoURL,
                                fullName: SevaCore.of(context)
                                            .loggedInUser
                                            .fullname !=
                                        null
                                    ? SevaCore.of(context).loggedInUser.fullname
                                    : S.of(context).anonymous_user,
                                createdEmail:
                                    SevaCore.of(context).loggedInUser.email,
                                createdAt:
                                    DateTime.now().millisecondsSinceEpoch,
                                comment: _textEditingController.text));

                            _textEditingController.clear();
                          }
                        }
                      },
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.sentiment_satisfied,
                        ),
                        iconSize: 30,
                        onPressed: () => {
                              setState(() {
                                isShowSticker = !isShowSticker;
                                if (isShowSticker) {
                                  FocusScope.of(context).unfocus();
                                } else {
                                  isShowSticker = false;
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                }
                              }),
                            }),
                  ],
                ),
              ),
            ),
            isProfane
                ? Container(
                    margin: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorText,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  )
                : Offstage(),
            (isShowSticker ? buildSticker() : Container()),
          ],
        ),
      ),
    );
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        _textEditingController.text += emoji.emoji;
      },
    );
  }

  Widget CommentContainer(Comments commentsList, double size, double width,
      bool isParent, int index) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserProfileImage(
            photoUrl: commentsList.userPhotoURL,
            email: widget.feed.email,
            userId: widget.feed.sevaUserId,
            height: 30,
            width: 30,
            timebankModel: widget.timebankModel,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${commentsList.fullName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 0),
                  child: Text(
                      timeAgo.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              commentsList.createdAt),
                          locale: Locale(getLangTag()).toLanguageTag()),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 0, 0, 0.5))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - width,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${commentsList.comment}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        InkWell(
                          onTap: () {
                            Set<String> likesList =
                                Set.from(commentsList.likes);
                            commentsList.likes != null &&
                                    commentsList.likes
                                        .contains(commentsList.createdEmail)
                                ? likesList.remove(commentsList.createdEmail)
                                : likesList.add(commentsList.createdEmail);
                            commentsList.likes = likesList.toList();
                            setState(() {
                              isParent
                                  ? widget.feed.comments[widget.index].likes =
                                      likesList.toList()
                                  : widget
                                      .feed
                                      .comments[widget.index]
                                      .comments[index]
                                      .likes = likesList.toList();
                            });
                            NewsService().updateFeed(newsModel: widget.feed);
                            setState(() {});
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: commentsList.likes != null &&
                                    commentsList.likes
                                        .contains(commentsList.createdEmail)
                                ? Icon(
                                    Icons.favorite,
                                    color: Color(0xFFec444b),
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${commentsList.likes.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2, top: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.of(context).like + 's',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //     padding: EdgeInsets.only(left: 12, top: 0),
                    //     child: InkWell(
                    //         onTap: () {},
                    //         child: Text('Reply',
                    //             style: TextStyle(
                    //               fontSize: 11,
                    //               fontWeight: FontWeight.bold,
                    //               color: Color.fromRGBO(0, 0, 0, 0.5),
                    //             )))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
