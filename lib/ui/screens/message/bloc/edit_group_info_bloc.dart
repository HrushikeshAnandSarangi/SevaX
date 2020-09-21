import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';

import 'create_chat_bloc.dart';

class EditGroupInfoBloc {
  final _chatModel = BehaviorSubject<ChatModel>();
  final _file = BehaviorSubject<MessageRoomImageModel>();
  final _groupName = BehaviorSubject<String>();
  final _participantInfo = BehaviorSubject<List<ParticipantInfo>>();
  final profanityDetector = ProfanityDetector();

  Stream<String> get groupName => _groupName.stream;
  Stream<MessageRoomImageModel> get image => _file.stream;
  Stream<ChatModel> get chatModel => _chatModel.stream;
  Stream<List<ParticipantInfo>> get participants => _participantInfo.stream;

  List<ParticipantInfo> get participantsList => _participantInfo.value;

  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(MessageRoomImageModel) get onImageChanged => _file.sink.add;
  Function(List<ParticipantInfo>) get addParticipants =>
      _participantInfo.sink.add;

  Future<ChatModel> getChatModel(String chatId) async {
    return await ChatsRepository.getChatModel(chatId);
  }

  void removeMember(String userId) {
    List<ParticipantInfo> infos = _participantInfo.value;
    infos.removeWhere((ParticipantInfo info) => info.id == userId);
    _participantInfo.add(infos);
  }

  Future<void> editGroupDetails(String chatId) async {
    if (_groupName.value == null || _groupName.value.isEmpty) {
      _groupName.addError("Group name cannot be empty");
    } else if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError('profanity');
    } else {
      String imageUrl;

      if (_file.value != null && _file.value.selectedImage != null) {
        imageUrl = _file.value != null
            ? await StorageRepository.uploadFile(
                "multiUserMessagingLogo", _file.value.selectedImage)
            : null;
      } else if (_file.value != null && _file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      } else {
        return null;
      }
      print("image url ${imageUrl}");

      ChatsRepository.editGroup(
          chatId, _groupName.value, imageUrl, _participantInfo.value);
    }
  }

  void dispose() {
    _chatModel.close();
    _file.close();
    _groupName.close();
    _participantInfo.close();
  }
}
