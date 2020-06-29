import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';

//to sync chatModel with chats as a member is added or removed
class ChatModelSync {
  ChatModelSync._privateConstructor();

  final _chatModels = BehaviorSubject<List<ChatModel>>();

  bool get isClosed => _chatModels.isClosed;

  Function(List<ChatModel>) get addChatModels => _chatModels.sink.add;
  Stream<List<ChatModel>> get chatModels => _chatModels.stream;

  void dispose() {
    _chatModels.close();
  }

  static final ChatModelSync _instance = ChatModelSync._privateConstructor();

  factory ChatModelSync() {
    return _instance;
  }
}
