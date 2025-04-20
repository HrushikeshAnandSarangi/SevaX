import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/user_model.dart';

class ShareFeedModel {
  final ChatModel? chatModel;
  final MessageModel? messageModel;

  ShareFeedModel({this.chatModel, this.messageModel});
}

class SearchResultModel {
  final UserModel? userModel;
  final bool? isSelected;

  SearchResultModel({this.userModel, this.isSelected});
}
