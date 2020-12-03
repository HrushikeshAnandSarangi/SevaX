import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/ui/screens/add_manual_time/bloc/add_manual_time_bloc.dart';
import 'package:sevaexchange/views/core.dart';

class AddMnualTimeDetailsPage extends StatefulWidget {
  final String typeId;
  final ManualTimeType type;
  final UserRole userType;
  final String timebankId;

  const AddMnualTimeDetailsPage({
    Key key,
    @required this.typeId,
    @required this.type,
    @required this.userType,
    @required this.timebankId,
  }) : super(key: key);
  @override
  _AddMnualTimeDetailsPageState createState() =>
      _AddMnualTimeDetailsPageState();
}

class _AddMnualTimeDetailsPageState extends State<AddMnualTimeDetailsPage> {
  final AddManualTimeBloc _bloc = AddManualTimeBloc();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          'Add Manual Time',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<String>(
              stream: _bloc.reason,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _bloc.onReasonChanged,
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    disabledBorder: border,
                    focusedBorder: border,
                    hintText: 'Why are you adding this time? Please specify',
                    errorText: snapshot.hasError
                        ? S.of(context).validation_error_general_text
                        : null,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text('Select time'),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: _bloc.onHoursChanged,
                          ),
                          Text(S.of(context).hour(3)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          circularDot(),
                          SizedBox(height: 8),
                          circularDot(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder<String>(
                            stream: _bloc.minutes,
                            builder: (context, snapshot) {
                              return DropdownButtonFormField<String>(
                                value: snapshot.data ?? '0',
                                items:
                                    List.generate(12, (index) => '${index * 5}')
                                        .map((value) {
                                  return DropdownMenuItem(
                                      child: Text(value), value: value);
                                }).toList(),
                                onChanged: _bloc.onMinutesChanged,
                              );
                            },
                          ),
                          Text(S.of(context).minutes),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                StreamBuilder<bool>(
                    initialData: false,
                    stream: _bloc.error,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? false
                            ? S.of(context).validation_error_invalid_hours
                            : '',
                        style: TextStyle(color: Colors.red),
                      );
                    }),
              ],
            ),
          ),
          SizedBox(height: 20),
          RaisedButton(
            child: Text('Create Request'),
            onPressed: () {
              try {
                _bloc
                    .claim(
                  SevaCore.of(context).loggedInUser,
                  widget.type,
                  widget.typeId,
                  widget.timebankId,
                  widget.userType,
                )
                    .then(
                  (value) {
                    if (value) {
                      _key.currentState.hideCurrentSnackBar();
                      _key.currentState.showSnackBar(
                        SnackBar(
                          content: Text('Claimed Successfully'),
                        ),
                      );
                      Future.delayed(Duration(seconds: 2), () {
                        Navigator.of(context).pop();
                      });
                    }
                  },
                );
              } catch (e) {
                _key.currentState.hideCurrentSnackBar();
                _key.currentState.showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).general_stream_error),
                    action: SnackBarAction(
                      label: S.of(context).dismiss,
                      onPressed: () {
                        _key.currentState.hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget circularDot() {
    return Container(
      height: 2,
      width: 2,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
