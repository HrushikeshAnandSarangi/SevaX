import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';

import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';

class SelectRequestView extends StatefulWidget {
  final OfferModel offerModel;
  final String sevaUserIdOffer;

  SelectRequestView({@required this.offerModel, this.sevaUserIdOffer});

  @override
  _SelectRequestViewState createState() =>
      _SelectRequestViewState(sevaUserId: sevaUserIdOffer);
}

class _SelectRequestViewState extends State<SelectRequestView> {
  RequestModel selectedRequestModel;
  bool isofferrequest = false;
  final String sevaUserId;
  _SelectRequestViewState({this.sevaUserId});
  List<RequestModel> requestList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    FirestoreManager.getRequestStreamCreatedByUser(
            sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID)
        .listen(
      (requestList) {
        if (!mounted) return;
        setState(
          () => this.requestList = requestList,
        );
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Select Request',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Your Requests'),
                SizedBox(height: 8.0),
                () {
                  if (requestList.length != 0) {
                    return DropdownButton<RequestModel>(
                      hint: Text('Select a request'),
                      items: requestList.map((model) {
                        return DropdownMenuItem<RequestModel>(
                          child: Text(model.title),
                          value: model,
                        );
                      }).toList(),
                      onChanged: (model) {
                        setState(() {
                          this.selectedRequestModel = model;
                        });
                      },
                      value: selectedRequestModel,
                    );
                  } else {
                    return Text(
                      'You do not have any active requests',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }
                }(),
                SizedBox(height: 16),
                FlatButton(
                  onPressed: () {
                    isofferrequest = true;
                    print('at Select request = $isofferrequest');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return CreateRequest(
                            isOfferRequest: isofferrequest,
                            offer: widget.offerModel,
                            timebankId: FlavorConfig.values.timebankId,
                          );
                        },
                      ),
                    );
                  },
                  child: Text('Create a request'),
                  textColor: Colors.blueAccent,
                ),
                selectedRequestModel == null ? Offstage() : selectedRequest,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get selectedRequest {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 16.0,
      ),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              offset: Offset(0, 3),
              spreadRadius: 2,
              blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(
              selectedRequestModel.title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: RichTextView(text: selectedRequestModel.description),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(
              'From:  ' +
                  DateFormat('MMMM dd, yyyy @ h:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        selectedRequestModel.requestStart),
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(
              'Until:  ' +
                  DateFormat('MMMM dd, yyyy @ h:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        selectedRequestModel.requestEnd),
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text('Posted By: ' + selectedRequestModel.fullName),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(
              'PostDate:  ' +
                  DateFormat('MMMM dd, yyyy @ h:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        selectedRequestModel.postTimestamp),
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(
                'Number of volunteers required: ${selectedRequestModel.numberOfApprovals}'),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(' '),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: RaisedButton(
              color: Colors.deepPurple,
              onPressed: () {
                OfferModel offer = widget.offerModel;
                //String sevaUserIdOffer = offer.sevaUserId;

                Set<String> offerRequestList = () {
                  if (offer.requestList == null) return [];
                  return offer.requestList;
                }()
                    .toSet();
                offerRequestList.add(selectedRequestModel.id);
                offer.requestList = offerRequestList.toList();
                FirestoreManager.updateOfferWithRequest(offer: offer);
                sendOfferRequest(
                    offerModel: offer,
                    requestSevaID: selectedRequestModel.sevaUserId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'Send Request',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
