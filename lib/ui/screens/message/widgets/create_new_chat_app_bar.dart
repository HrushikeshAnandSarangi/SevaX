import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_group.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class CreateNewChatAppBar extends PreferredSize {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final bool isSelectionEnabled;

  CreateNewChatAppBar({
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
                customButton("Cancel", Navigator.of(context).pop),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSelectionEnabled ? "Add Participants" : "New Chat",
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
                              ? customButton("Next", () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute<String>(
                                      builder: (context) =>
                                          CreateGroupPage(bloc: _bloc),
                                    ),
                                  )
                                      .then((String value) {
                                    if (value == "success")
                                      Navigator.of(context).pop();
                                  });
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
                    hintText: AppLocalizations.of(context)
                        .translate("search_page", "search"),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
