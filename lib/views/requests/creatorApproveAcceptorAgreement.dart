import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CreatorApproveAcceptorAgreeement extends StatefulWidget {
  final String timeBankId;
  final String userId;
  final RequestModel requestModel;
  final BuildContext parentContext;
  final UserModel acceptorUserModel;
  final String notificationId;
  //final VoidCallback onTap;

  const CreatorApproveAcceptorAgreeement({
    Key? key,
    required this.timeBankId,
    required this.userId,
    required this.requestModel,
    required this.parentContext,
    required this.acceptorUserModel,
    required this.notificationId,
    //this.onTap,
  }) : super(key: key);

  @override
  _CreatorApproveAcceptorAgreeementState createState() =>
      _CreatorApproveAcceptorAgreeementState();
}

class _CreatorApproveAcceptorAgreeementState
    extends State<CreatorApproveAcceptorAgreeement> {
  GeoFirePoint? location;
  String selectedAddress = '';
  String doAndDonts = '';

  String borrowAgreementLinkFinal = '';
  String documentName = '';
  BorrowAcceptorModel? borrowAcceptorModel;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          widget.requestModel.roomOrTool == 'PLACE'
              ? S.of(context).accept_place_borrow_request
              : S.of(context).accept_item_borrow_request,
          style: TextStyle(
              fontFamily: "Europa", fontSize: 19, color: Colors.white),
        ),
      ),
      body: FutureBuilder<BorrowAcceptorModel>(
          future: FirestoreManager.getBorrowRequestAcceptorModel(
              requestId: widget.requestModel.id!,
              acceptorEmail: widget.acceptorUserModel.email!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data == null) {
              return Center(
                child: Text(S.of(context).no_data),
              );
            }
            borrowAcceptorModel = snapshot.data;
            return SingleChildScrollView(
              child: mainPageAgreementComponent,
            );
          }),
    );
  }

  Widget get mainPageAgreementComponent {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 10),
            requestAgreementFormComponent,
            borrowAcceptorModel!.borrowAgreementLink != null &&
                    borrowAcceptorModel!.borrowAgreementLink != ''
                ? termsAcknowledegmentText
                : Container(),
            SizedBox(height: 20),
            bottomActionButtons,
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget get termsAcknowledegmentText {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: Colors.grey[200], size: 40),
                Icon(Icons.check, color: Colors.green, size: 30),
              ],
            ),
            SizedBox(width: 15),
            Container(
              width: 290,
              child: Text(
                  S.of(context).terms_acknowledgement_text +
                      '. ' +
                      S.of(context).agree_to_signature_legal_text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.start),
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget get bottomActionButtons {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 32,
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2.0,
            textColor: Colors.white,
            child: Text(
              S.of(context).accept,
              style: TextStyle(color: Colors.white, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              approveMemberForVolunteerRequest(
                model: widget.requestModel,
                notificationId: widget.notificationId,
                user: widget.acceptorUserModel,
                context: context,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2.0,
            textColor: Colors.white,
            child: Text(
              S.of(context).reject,
              style: TextStyle(color: Colors.white, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              declineRequestedMember(
                model: widget.requestModel,
                notificationId: widget.notificationId,
                user: widget.acceptorUserModel,
                context: context,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Colors.grey[300]!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2.0,
            textColor: Colors.black,
            child: Text(
              S.of(context).message,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;

              ParticipantInfo sender = ParticipantInfo(
                id: loggedInUser.sevaUserID,
                name: loggedInUser.fullname,
                photoUrl: loggedInUser.photoURL,
                type: widget.requestModel.requestMode ==
                        RequestMode.TIMEBANK_REQUEST
                    ? ChatType.TYPE_TIMEBANK
                    : ChatType.TYPE_PERSONAL,
              );

              ParticipantInfo reciever = ParticipantInfo(
                id: widget.acceptorUserModel.sevaUserID,
                name: widget.acceptorUserModel.fullname,
                photoUrl: widget.acceptorUserModel.photoURL,
                type: ChatType.TYPE_PERSONAL,
              );

              createAndOpenChat(
                context: context,
                communityId: loggedInUser.currentCommunity!,
                sender: sender,
                reciever: reciever,
                timebankId: widget.timeBankId,
                feedId: widget.requestModel.id!,
                showToCommunities: [loggedInUser.currentCommunity!],
                entityId: widget.requestModel.id!,
                onChatCreate: () {
                  //Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get requestAgreementFormComponent {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              S.of(context).agreement,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.68,
              child: Text(
                borrowAcceptorModel!.borrowAgreementLink != null &&
                        borrowAcceptorModel!.borrowAgreementLink != ''
                    ? S.of(context).review_before_proceding_text
                    : (widget.requestModel.roomOrTool == 'PLACE'
                        ? S.of(context).lender_not_accepted_request_msg_place
                        : S.of(context).lender_not_accepted_request_msg_item),
                style: TextStyle(fontSize: 15),
                softWrap: true,
              ),
            ),
            Image(
              width: 60,
              image: AssetImage(
                  'lib/assets/images/request_offer_agreement_icon.png'),
            ),
          ],
        ),
        SizedBox(height: 20),
        borrowAcceptorModel!.borrowAgreementLink != null &&
                borrowAcceptorModel!.borrowAgreementLink != ''
            ? Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
                alignment: Alignment.center,
                width: 300,
                height: 360,
                child: SfPdfViewer.network(
                  borrowAcceptorModel!.borrowAgreementLink!,
                  canShowPaginationDialog: false,
                ),
              )
            : Container(),
        SizedBox(height: 20),
        borrowAcceptorModel!.borrowAgreementLink != null &&
                borrowAcceptorModel!.borrowAgreementLink != ''
            ? Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 12),
                width: 155,
                height: 32,
                child: CustomTextButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0),
                  color: borrowAcceptorModel!.borrowAgreementLink != null &&
                          borrowAcceptorModel!.borrowAgreementLink != ''
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 1),
                      Spacer(),
                      Text(
                        borrowAcceptorModel!.borrowAgreementLink != null &&
                                borrowAcceptorModel!.borrowAgreementLink != ''
                            ? S.of(context).review_agreement
                            : S.of(context).no_agrreement,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (borrowAcceptorModel!.borrowAgreementLink != null &&
                        borrowAcceptorModel!.borrowAgreementLink != '') {
                      await openPdfViewer(
                          borrowAcceptorModel!.borrowAgreementLink,
                          'Review Agreement',
                          context);
                    } else {
                      return;
                    }
                  },
                ),
              )
            : Container(),
      ],
    );
  }

  Future<void> approveMemberForVolunteerRequest({
    RequestModel? model,
    UserModel? user,
    String? notificationId,
    required BuildContext context,
  }) async {
    List<String> approvedUsers = model!.approvedUsers!;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user!.email!);
    model.approvedUsers = usersSet.toList();

    ((model.numberOfApprovals != null &&
                model.numberOfApprovals! <= model.approvedUsers!.length) ||
            model.approvedUsers!.length == 0)
        ? model.accepted == true
        : null;

    FirestoreManager.approveAcceptRequestForTimebank(
      requestModel: model,
      approvedUserId: user.sevaUserID!,
      notificationId: notificationId!,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity!,
    );
  }

  void declineRequestedMember({
    RequestModel? model,
    UserModel? user,
    String? notificationId,
    BuildContext? context,
  }) {
    List<String> acceptedUsers = model!.acceptors!;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user!.email);
    model.acceptors = usersSet.toList();

    FirestoreManager.rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID!,
      notificationId: notificationId!,
      communityId: SevaCore.of(context!).loggedInUser.currentCommunity!,
    );
  }

  Future<void> openPdfViewer(
      String? pdfUrl, String title, BuildContext context) async {
    if (pdfUrl == null || pdfUrl.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SfPdfViewer.network(pdfUrl),
        ),
      ),
    );
  }
}
