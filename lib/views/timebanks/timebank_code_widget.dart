import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:share_plus/share_plus.dart';

import '../../flavor_config.dart';

class TimebankCodeWidget extends StatefulWidget {
  final Color? buttonColor;
  final TimebankCodeModel? timebankCodeModel;
  final String? timebankName;
  final UserModel? user;

  TimebankCodeWidget(this.buttonColor,
      {this.timebankCodeModel, this.timebankName, @required this.user});

  @override
  _TimebankCodeWidgetState createState() => _TimebankCodeWidgetState();
}

class _TimebankCodeWidgetState extends State<TimebankCodeWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 10),
            ],
          ),
          Container(
            width: 800,
            margin: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 10,
            ),
            child: Card(
              child: Container(
                margin: const EdgeInsets.only(left: 10, bottom: 20, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: headingTitle(
                        S.of(context).copy_and_share_code,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        width: 320,
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        // height: 125,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SelectableText(
                                S.of(context).timebank_code +
                                    widget.timebankCodeModel!.timebankCode!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                S.of(context).not_yet_redeemed,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                DateTime.now().millisecondsSinceEpoch >
                                        widget.timebankCodeModel!.validUpto!
                                    ? S.of(context).expired
                                    : S.of(context).active,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Tooltip(
                                    message: S.of(context).copy_community_code,
                                    child: InkWell(
                                      onTap: () {
                                        ClipboardData data = ClipboardData(
                                            text: shareText(
                                          widget!.timebankCodeModel!,
                                          widget.user!.fullname!,
                                        ));
                                        Clipboard.setData(data);

                                        SnackBar snackbar = SnackBar(
                                          content: Text(S
                                              .of(context)
                                              .copied_to_clipboard),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      },
                                      child: Text(
                                        S.of(context).copy_code,
                                        style: TextStyle(
                                          color: widget.buttonColor ??
                                              Theme.of(context).primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                      ),
                                      iconSize: 25,
                                      onPressed: () async {
                                        await deleteShareCode(widget
                                            .timebankCodeModel!
                                            .timebankCodeId!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                        child: Text(
                      widget.timebankCodeModel!.timebankCode!,
                      style: TextStyle(fontSize: 36, color: Colors.black54),
                    )),
                    Center(
                      child: CustomElevatedButton(
                        onPressed: () {
                          Share.share(
                            shareText(
                              widget.timebankCodeModel!,
                              widget.user!.fullname!,
                            ),
                          );
                        },
                        // color: Colors.red,
                        color: widget.buttonColor ??
                            Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        child: Text(S.of(context).share_code),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                        child: Text(
                      S.of(context).share_code_msg,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String shareText(TimebankCodeModel timebankCode, String name) {
    return '''$name ${S.of(context).has_invited_you_to_join_their} 
    "${widget.timebankName}" ${S.of(context).seva_community_seva_means_selfless_service_in_Sanskrit}.
     ${S.of(context).seva_ommunities_are_based_on_a_mutual_reciprocity_system},
      ${S.of(context).where_community_members_help_each_other_out_in_exchange_for_seva_credits_that_can_be_redeemed_for_services_they_need}.
       ${S.of(context).to_learn_more_about_being_a_part_of_a_Seva_Community_here_s_a_short_explainer_video}.
        https://youtu.be/xe56UJyQ9ws \n\n${S.of(context).here_is_what_you_ll_need_to_know} \n${S.of(context).first_text},
         ${S.of(context).depending_on_where_you_click_the_link_from_whether_it_s_your_web_browser_or_mobile_phone},
          ${S.of(context).the_link_will_either_take_you_to_our_main} https://www.sevaxapp.com ${S.of(context).web_page_where_you_can_register_on_the_web_directly_or_it_will_take_you_from_your_mobile_phone_to_the_App_or_google_play_stores}, 
         ${S.of(context).where_you_can_download_our_SevaX_App_Once_you_have_registered_on_the_SevaX_mobile_app_or_the_website},
           ${S.of(context).you_can_explore_Seva_Communities_near_you_Type_in_the} "${widget.timebankName}" ${S.of(context).and_enter_code_text} "${timebankCode.timebankCode}" ${S.of(context).when_prompted_text}.
           \n\n${S.of(context).click_to_Join_text} $name 
           ${S.of(context).and_their_Seva_Community_via_this_dynamic_link_at} https://sevaexchange.page.link/sevaxapp.
           \n\n${S.of(context).thank_you_for_being_a_part_of_our_Seva_Exchange_movement_the_Seva_Exchange_team_Please_email_us_at} 
           ${S.of(context).if_you_have_any_questions_or_issues_joining_with_the_link_given}.
    ''';
  }

  Future<void> deleteShareCode(String timebankCodeId) async {
    await CollectionRef.timebankCodes.doc(timebankCodeId).delete();
  }

  Widget headingTitle(String label) {
    return Container(
      height: 25,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
