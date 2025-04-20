import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/timebank_message_page.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminMessageCard extends StatelessWidget {
  final AdminMessageWrapperModel? model;
  const AdminMessageCard({
    Key? key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => Navigator.of(context).push(
              TimebankMessagePage.route(
                adminMessageWrapperModel: model!,
                // Make sure 'communityId' exists in AdminMessageWrapperModel
                // If the correct property is named differently, for example 'communityID' or 'community', use that instead:
                communityId: model!.id,
                // or
                // communityId: model!.community,
              ),
            ),
            child: Row(
              children: <Widget>[
                model?.photoUrl != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            CachedNetworkImageProvider(model!.photoUrl),
                      )
                    : CustomAvatar(
                        name: model!.name,
                        radius: 30,
                      ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    model?.newMessageCount != null && model!.newMessageCount > 0
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            color: Colors.grey[300],
                            child: Text(
                              getMessageCountText(
                                  model?.newMessageCount ?? 0, context),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Divider(
                  thickness: 1,
                  // color: Colors.grey,
                ),
              ),
              SizedBox(width: 20),
              Text(
                model?.timestamp == null
                    ? ""
                    : timeago.format(model!.timestamp,
                        locale: Locale(getLangTag()).toLanguageTag()),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getMessageCountText(int count, BuildContext context) {
    if (count == null || count < 1) {
      return "";
    }
    if (count == 1) {
      return "1 ${S.of(context).new_message_text}";
    } else {
      return "$count ${S.of(context).new_messages_text}";
    }
  }
}
