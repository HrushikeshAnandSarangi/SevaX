import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/ui/screens/add_manual_time/bloc/add_manual_time_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class AddMnualTimeDetailsPage extends StatefulWidget {
  final String typeId;
  final ManualTimeType type;
  final UserRole userType;
  final String timebankId;
  final String communityName;

  const AddMnualTimeDetailsPage({
    Key? key,
    required this.typeId,
    required this.type,
    required this.userType,
    required this.timebankId,
    required this.communityName,
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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).manual_time_add,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    S.of(context).manual_time_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 8),
                  Text(
                    S.of(context).manual_time_info,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
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
                      hintText: S.of(context).manual_time_textfield_hint,
                      errorText: snapshot.hasError
                          ? S.of(context).validation_error_general_text
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(S.of(context).select_time),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^[0-9]*$"))
                              ],
                              onChanged: _bloc.onHoursChanged,
                            ),
                            Text(
                                toBeginningOfSentenceCase(S.of(context).hours)),
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
                                  items: List.generate(
                                          12, (index) => '${index * 5}')
                                      .map((value) {
                                    return DropdownMenuItem(
                                        child: Text(value), value: value);
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      _bloc.onMinutesChanged(newValue);
                                    }
                                  },
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
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2.0,
              textColor: Colors.white,
              child: Text(S.of(context).manual_time_button_text),
              onPressed: isLoading
                  ? () {}
                  : () {
                      try {
                        changeLoadingState(true);
                        _bloc
                            .claim(
                          SevaCore.of(context).loggedInUser,
                          widget.type,
                          widget.typeId,
                          widget.timebankId,
                          widget.communityName,
                          widget.userType,
                        )
                            .then(
                          (value) {
                            if (value) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(S.of(context).claimed_successfully),
                                ),
                              );
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.of(context).pop();
                              });
                            } else {
                              changeLoadingState(false);
                            }
                          },
                        ).catchError((onError) {
                          changeLoadingState(false);
                        });
                      } catch (e) {
                        changeLoadingState(false);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).general_stream_error),
                            action: SnackBarAction(
                              label: S.of(context).dismiss,
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void changeLoadingState(bool status) {
    setState(() {
      isLoading = status;
    });
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
