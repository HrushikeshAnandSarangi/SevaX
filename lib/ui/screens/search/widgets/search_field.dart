import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';

class SearchField extends StatelessWidget {
  SearchField({
    Key? key,
    required SearchBloc bloc,
    required TextEditingController controller,
  })  : _bloc = bloc,
        _controller = controller,
        super(key: key);

  final SearchBloc _bloc;
  final TextEditingController _controller;
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.transparent),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _bloc.searchText,
      builder: (context, snapshot) {
        return Container(
          height: 45,
          child: TextField(
            autofocus: true,
            controller: _controller,
            onChanged: _bloc.onSearchChange,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 15, top: 10),
              errorText: snapshot.error as String?,
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
                        _controller.clear();
                        _bloc.onSearchChange(null!);
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
