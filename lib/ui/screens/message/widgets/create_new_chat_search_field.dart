import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class CreateNewChatSearchField extends PreferredSize {
  CreateNewChatSearchField({
    Key key,
    @required TextEditingController controller,
    this.onChanged,
  }) : _controller = controller;

  final ValueChanged<String> onChanged;
  final TextEditingController _controller;
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.transparent),
  );

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return StreamBuilder<String>(
      stream: _bloc.searchText,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          height: 60,
          child: TextField(
            controller: _controller,
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
                        _controller.clear();
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
    );
  }
}
