import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_group.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class CreateNewChatAppBar extends PreferredSize {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final bool isSelectionEnabled;
  final bool isFromEditGroup;

  CreateNewChatAppBar({
    this.isFromEditGroup = false,
    this.isSelectionEnabled,
    this.controller,
    this.onChanged,
  });

  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.transparent),
  );

  @override
  Size get preferredSize => Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: preferredSize.height / 2,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                customButton(S.of(context).cancel, Navigator.of(context).pop),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSelectionEnabled ? S.of(context).add_participants : S.of(context).new_chat,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    isSelectionEnabled
                        ? StreamBuilder<List<String>>(
                            stream: _bloc.selectedMembers,
                            builder: (context, snapshot) {
                              return Text(
                                "${snapshot.data?.length ?? 0}/256",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : Container(),
                  ],
                ),
                Spacer(),
                isSelectionEnabled
                    ? StreamBuilder<List<String>>(
                        stream: _bloc.selectedMembers,
                        builder: (context, snapshot) {
                          return (snapshot.data?.length ?? 0) > 0
                              ? customButton(S.of(context).next, () {
                                  if (isFromEditGroup) {
                                    _bloc.selectedMembers.first.then((List<String> members) {
                                      List<ParticipantInfo> infos = List.generate(
                                        members.length,
                                        (index) => _bloc.allMembers[members[index]],
                                      );

                                      Navigator.of(context).pop(infos);
                                    });
                                  } else {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute<ChatModel>(
                                        builder: (context) => CreateGroupPage(bloc: _bloc),
                                      ),
                                    )
                                        .then((ChatModel value) {
                                      if (value != null) Navigator.of(context).pop(value);
                                    });
                                  }
                                })
                              : Container(width: 40);
                        })
                    : Container(width: 40),
              ],
            ),
          ),
          StreamBuilder<String>(
            stream: _bloc.searchText,
            builder: (context, snapshot) {
              return Container(
                padding: const EdgeInsets.all(10),
                height: preferredSize.height / 2,
                child: TextField(
                  controller: controller,
                  onChanged: _bloc.onSearchChanged,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 15, top: 10),
                    errorText: snapshot.error,
                    hintText: S.of(context).search,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Offstage(
                      offstage: !(snapshot.hasData ?? false),
                      child: IconButton(
                        icon: Icon(Icons.cancel),
                        color: Colors.grey,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) {
                              controller.clear();
                              _bloc.onSearchChanged(null);
                            },
                          );
                        },
                      ),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget customButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
