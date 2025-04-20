import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/create_new_chat_app_bar.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_list_builder.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

import 'new_chat_page.dart';

class CreateNewChatPage extends StatefulWidget {
  final bool isSelectionEnabled;
  final List<FrequentContactsModel> frequentContacts;
  final List<String>? selectedMembers;

  const CreateNewChatPage({
    Key? key,
    required this.isSelectionEnabled,
    required this.frequentContacts,
    this.selectedMembers,
  });
  @override
  _CreateNewChatPageState createState() => _CreateNewChatPageState();
}

class _CreateNewChatPageState extends State<CreateNewChatPage> {
  late CreateChatBloc _bloc;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    _bloc = CreateChatBloc(widget.isSelectionEnabled);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc
          .getMembers(
        SevaCore.of(context).loggedInUser,
        SevaCore.of(context).loggedInUser.currentCommunity ?? '',
        Provider.of<HomePageBaseBloc>(context, listen: false)
            .primaryTimebankModel()
            .id,
      )
          .then((_) {
        if (widget.selectedMembers != null) {
          widget.selectedMembers!
              .forEach((String id) => _bloc.selectMember(id));
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
        appBar: CreateNewChatAppBar(
          controller: textController,
          onChanged: (String value) {},
          isSelectionEnabled: widget.isSelectionEnabled,
          isFromEditGroup: widget.selectedMembers != null,
        ),
        body: StreamBuilder(
          stream: _bloc.searchText,
          builder: (_, AsyncSnapshot<String> snapshot) {
            if (snapshot.data != null && snapshot.data != '') {
              return MemberListBuilder(
                infos: _bloc.getFilteredListOfParticipants(snapshot.data ?? ''),
              );
            }
            return NewChatPage(
              key: UniqueKey(),
              frequentContacts: widget.frequentContacts,
            );
          },
        ),
      ),
    );
  }

  Widget customButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
