import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ProjectDescriptionBloc extends BlocBase {
  final _chatModel = BehaviorSubject<ChatModel>();

  Stream<ChatModel> get chatModel => _chatModel.stream;

  void init(String chatId) {
    logger.e("chat id is $chatId");
    if (chatId == null) return;
    CollectionRef.chats.doc(chatId).snapshots().listen((event) {
      var model = ChatModel.fromMap(event.data() as Map<String, dynamic>);
      model.id = event.id;
      _chatModel.add(model);
    });
  }

  @override
  void dispose() {
    _chatModel.close();
  }
}
