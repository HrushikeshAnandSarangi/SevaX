import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/invoice_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import 'invoice_pdf.dart';
import 'report_pdf.dart';

class MonthsListing extends StatefulWidget {
  final String communityId;
  final String planId;
  final CommunityModel communityModel;

  const MonthsListing.of({
    required this.communityId,
    required this.planId,
    required this.communityModel,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MonthsListingState();
  }
}

class _MonthsListingState extends State<MonthsListing> {
  String communityId = "";
  late CommunityModel communityModel;
  String planId = "";
  List<String> monthsArr = [
    "January",
    "Febuary",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  Map<String, dynamic> plans = {
    "tall_plan": {
      "name": "Community Plan",
      "initial_transactions_amount": 15,
      "initial_transactions_qty": 50,
      "pro_data_bill_amount": 0.05,
    },
    "community_plus_plan": {
      "name": "Community Plus Plan",
      "initial_transactions_amount": 50,
      "initial_transactions_qty": 150,
      "pro_data_bill_amount": 0.05,
    },
    "grande_plan": {
      "name": "Non-Profit Plan",
      "initial_transactions_amount": 1500,
      "initial_transactions_qty": 3000,
      "pro_data_bill_amount": 0.03,
    },
    "venti_plan": {
      "name": "Enterprise Plan",
      "initial_transactions_amount": 2500,
      "initial_transactions_qty": 5000,
      "pro_data_bill_amount": 0.01,
    }
  };

  Map<String, dynamic> transactionTypes = {
    "quota_TypeJoinTimebank": {
      "name": "Total number of users in this Timebank",
      "billable": true,
    },
    "quota_TypeRequestApply": {
      "name": "Number of Requests applications",
      "billable": true,
    },
    "quota_TypeRequestCreation": {
      "name": "Number of Requests created",
      "billable": true,
    },
    "quota_TypeRequestAccepted": {
      "name": "Number of accepted members for all Requests",
      "billable": true,
    },
    "quota_TypeOfferCreated": {
      "name": "Number of Offers created",
      "billable": true,
    },
    "quota_TypeOfferAccepted": {
      "name": "Number of accepted members for all Offers",
      "billable": true,
    },
    // non-billable
    "quota_TypeNewsCreated": {
      "name": "Number of Feeds posted",
      "billable": false,
    },
    "quota_TypeMessageCreated": {
      "name": "Number of Messages created",
      "billable": false,
    },
    "quota_TypeMessageUpdated": {
      "name": "Number of Messages updated",
      "billable": false,
    },
    "quota_TypeRequestMarkedComplete": {
      "name": "Number of Requests completed",
      "billable": false,
    },
    "quota_TypeAdminReviewCompleted": {
      "name": "Number of Admin Reviews completed",
      "billable": false,
    },
    "quota_TypeRequestCreditApproval": {
      "name": "Number of credit approvals for Requests",
      "billable": false,
    },
    "quota_TypeUserRemovedFromTimebank": {
      "name": "Number of users removed from Timebank",
      "billable": false,
    },
    "quota_TypeCreateProject": {
      "name": "Number of Projects created",
      "billable": false,
    },
    "quota_TypeDeleteProject": {
      "name": "Number of Projects deleted",
      "billable": false,
    },
    "quota_TypeCreateGroup": {
      "name": "Number of Groups created",
      "billable": false,
    },
    "quota_TypeDeleteGroup": {
      "name": "Number of Groups deleted",
      "billable": false,
    },
    "quota_TypeMemberReported": {
      "name": "Number of Members reported",
      "billable": false,
    }
  };

  void initState() {
    super.initState();
    communityId = widget.communityId;
    planId = widget.planId;
    communityModel = widget.communityModel;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "${S.of(context).invoice_reports_list}",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: FirestoreManager.getTransactionsCountsList(communityId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text(S.of(context).no_record_transactions_yet,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            );
          }
          List<Map<String, dynamic>> transactionsMonthsList =
              snapshot.data as List<Map<String, dynamic>>;
          if (transactionsMonthsList == null) {
            return Center(
              child: Text(S.of(context).no_record_transactions_yet,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            );
          } else if (transactionsMonthsList.length == 0) {
            return Center(
              child: Text(S.of(context).no_record_transactions_yet,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            );
          }
          return ListView.builder(
              itemCount: transactionsMonthsList.length,
              itemBuilder: (context, index) {
                List<Detail> DetailsList = [];

                log(transactionsMonthsList[index]['id']);
                transactionsMonthsList[index].forEach((k, v) {
                  if (transactionTypes.containsKey(k)) {
                    log("$k -> $v");
                    DetailsList.add(Detail(
                      description: transactionTypes[k]["name"],
                      //                        units: transactionsMonthsList[index][k],
                      units: v.toDouble(),
                      price: transactionTypes[k]["billable"] == true
                          ? plans[planId]["pro_data_bill_amount"]
                          : 0,
                    ));
                  }
                  if (k == "planId") {
                    planId = v;
                  }
                });
                var sum = 0;
                transactionsMonthsList[index].forEach((k, v) {
                  if (transactionTypes.containsKey(k)) {
                    if (k != "billedquota") {
                      if (transactionTypes[k]["billable"] == true) {
                        sum += (v as int);
                      }
                    }
                  }
                });
                return Card(
                    child: ListTile(
                        title: Row(
                  children: [
                    Text(
                        "${monthsArr[int.parse(transactionsMonthsList[index]['id'].split('_')[0]) - 1]}  ${transactionsMonthsList[index]['id'].split('_')[1]} "),
                    Spacer(),
                    GestureDetector(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 15,
                        child: Image.asset(
                          "lib/assets/images/report_icon.jpeg",
                        ),
                      ),
                      onTap: () {
                        ReportPdf().reportPdf(
                            context,
                            InvoiceModel(
                                note1:
                                    "This report is for the billing period for the month of ${monthsArr[int.parse(transactionsMonthsList[index]['id'].split('_')[0]) - 1]}, ${transactionsMonthsList[index]['id'].split('_')[1]}",
                                note2:
                                    "Greetings from Seva Exchange. We're writing to provide you with a detailed report of your use of SevaX services. Additional information about your bill, individual service charge details, and your account history are available on the Billing section under Manage tab.",
                                details: DetailsList,
                                plans: plans),
                            communityModel,
                            transactionsMonthsList[index]['id'],
                            plans[planId]);
                      },
                    ),
                    SizedBox(width: 30),
                    GestureDetector(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 15,
                        child:
                            Image.asset("lib/assets/images/invoice_icon.jpeg"),
                      ),
                      onTap: () {
                        InvoicePdf().invoicePdf(
                            context,
                            InvoiceModel(
                                note1:
                                    "This invoice is for the billing period for the month of ${monthsArr[int.parse(transactionsMonthsList[index]['id'].split('_')[0]) - 1]}, ${transactionsMonthsList[index]['id'].split('_')[1]}",
                                note2:
                                    "Greetings from Seva Exchange. This is a summary statement of your utilization of services in the SevaX App. Additional information about your bill, details of individual service usage and your account history is available in the Billing section under the Manage tab.",
                                details: [
                                  Detail(
                                      description:
                                          "${planId == "tall_plan" ? "Monthly" : planId == "community_plus_plan" ? "Monthly" : planId == "neighbourhood_plan" ? "Monthly" : "Yearly"} ${plans[planId]["name"]} Initial Charges",
                                      units: 1.00,
                                      price: plans[planId]
                                              ["initial_transactions_amount"]
                                          .toDouble()),
                                  Detail(
                                      description: S
                                          .of(context)
                                          .additional_billable_transactions,
                                      units: sum.toDouble(),
                                      price: plans[planId]
                                              ["pro_data_bill_amount"]
                                          .toDouble()),
                                  Detail(
                                      description: S
                                          .of(context)
                                          .discounted_transactions_msg,
                                      units: plans[planId]
                                              ["initial_transactions_qty"]
                                          .toDouble(),
                                      price: plans[planId]
                                              ["pro_data_bill_amount"]
                                          .toDouble())
                                ],
                                plans: plans),
                            communityModel,
                            transactionsMonthsList[index]['id'],
                            plans[planId]);
                      },
                    ),
                  ],
                )));
              });
        },
      ),
    );
  }
}
