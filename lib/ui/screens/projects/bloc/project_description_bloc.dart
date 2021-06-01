
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ProjectDescriptionBloc extends BlocBase {
  final _chatModel = BehaviorSubject<ChatModel>();

  Stream<ChatModel> get chatModel => _chatModel.stream;

  void init(String chatId) {
    logger.e("chat id is $chatId");
    if (chatId == null) return;
    Firestore.instance
        .collection("chatsnew")
        .document(chatId)
        .snapshots()
        .listen((event) {
      var model = ChatModel.fromMap(event.data);
      model.id = event.documentID;
      _chatModel.add(model);
    });
  }

  @override
  void dispose() {
    _chatModel.close();
  }
}
