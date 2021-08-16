import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/exchange/create_request/request_create_form.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  final String projectId;
  final ComingFrom comingFrom;

  CreateRequest({
    Key key,
    @required this.comingFrom,
    this.isOfferRequest,
    this.offer,
    this.timebankId,
    this.userModel,
    this.projectId,
    this.projectModel,
  }) : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            CommonHelpIconWidget(),
          ],
        ),
        body: StreamBuilder<UserModelController>(
          stream: userBloc.getLoggedInUser,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Text(
                S.of(context).general_stream_error,
              );
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data != null) {
              return RequestCreateForm(
                comingFrom: widget.comingFrom,
                isOfferRequest: widget.offer != null ? widget.isOfferRequest : false,
                offer: widget.offer,
                timebankId: widget.timebankId,
                userModel: widget.userModel,
                loggedInUser: snapshot.data.loggedinuser,
                projectId: widget.projectId,
                projectModel: widget.projectModel,
              );
            }
            return Text('');
          },
        ),
      ),
    );
  }

  String get _title {
    if (widget.projectId == null || widget.projectId.isEmpty || widget.projectId == "") {
      return S.of(context).create_request;
    }
    return S.of(context).create_project_request;
  }
}

