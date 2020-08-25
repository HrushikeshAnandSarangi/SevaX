import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/invoice_model.dart';
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import 'invoice_pdf.dart';
import 'report_pdf.dart';

class MonthsListing extends StatefulWidget {
  final String communityId;
  final String planId;
  final CommunityModel communityModel;

  MonthsListing.of({this.communityId, this.planId, this.communityModel});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MonthsListingState();
  }
}

class _MonthsListingState extends State<MonthsListing> {
  String communityId = "";
  CommunityModel communityModel = null;
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
      "name": "Tall Plan",
      "initial_transactions_amount": 15,
      "initial_transactions_qty": 50,
      "pro_data_bill_amount": 0.05,
    },
    "grande_plan": {
      "name": "Grande Plan",
      "initial_transactions_amount": 1500,
      "initial_transactions_qty": 3000,
      "pro_data_bill_amount": 0.03,
    },
    "venti_plan": {
      "name": "Venti Plan",
      "initial_transactions_amount": 2500,
      "initial_transactions_qty": 5000,
      "pro_data_bill_amount": 0.01,
    }
  };

  Map<String, dynamic> transactionTypes = {
    "quota_TypeJoinTimebank": {
      "name": "Total Users Who Joined this timebank",
      "billable": true,
    },
    "quota_TypeRequestApply": {
      "name": "Total Requests Applications",
      "billable": true,
    },
    "quota_TypeRequestCreation": {
      "name": "Total Requests Created",
      "billable": true,
    },
    "quota_TypeRequestAccepted": {
      "name": "Total Accepted Members For All Requests",
      "billable": true,
    },
    "quota_TypeOfferCreated": {
      "name": "Total Offers Created",
      "billable": true,
    },
    "quota_TypeOfferAccepted": {
      "name": "Total Accepted Members For All Offers",
      "billable": true,
    },
    // non-billable
    "quota_TypeNewsCreated": {
      "name": "Total Feeds Created",
      "billable": false,
    },
    "quota_TypeMessageCreated": {
      "name": "Total Messages Created",
      "billable": false,
    },
    "quota_TypeMessageUpdated": {
      "name": "Total Messages Updated",
      "billable": false,
    },
    "quota_TypeRequestMarkedComplete": {
      "name": "Total Requests Completed",
      "billable": false,
    },
    "quota_TypeAdminReviewCompleted": {
      "name": "Total Admin Reviews Completed",
      "billable": false,
    },
    "quota_TypeRequestCreditApproval": {
      "name": "Total Credit Approvals For Requests",
      "billable": false,
    },
    "quota_TypeUserRemovedFromTimebank": {
      "name": "Total Users Removed From Timebank",
      "billable": false,
    },
    "quota_TypeCreateProject": {
      "name": "Total Projects Created",
      "billable": false,
    },
    "quota_TypeDeleteProject": {
      "name": "Total Projects Deleted",
      "billable": false,
    },
    "quota_TypeCreateGroup": {
      "name": "Total Groups Created",
      "billable": false,
    },
    "quota_TypeDeleteGroup": {
      "name": "Total Groups Deleted",
      "billable": false,
    },
    "quota_TypeMemberReported": {
      "name": "Total Members Reported",
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
          "Invoice/Reports List",
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
          List<Map<String, dynamic>> transactionsMonthsList = snapshot.data;

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
                });
                var sum = 0;
                transactionsMonthsList[index].forEach((k, v) {
                  if (transactionTypes.containsKey(k)) {
                    if (transactionTypes[k]["billable"] == true) {
                      sum += v;
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
                                    "Greetings from Seva Exchange. We're writing to provide you with a detailed report of your use of SevaX services. Additional information about your bill, individual service charge details, and your account history are available on the Billing section under Manage tab.",
                                details: [
                                  Detail(
                                      description:
                                          "${planId == "tall_plan" ? "Monthly" : "Yearly"} ${plans[planId]["name"]} Initial Charges",
                                      units: 1.00,
                                      price: plans[planId]
                                              ["initial_transactions_amount"]
                                          .toDouble()),
                                  Detail(
                                      description:
                                          "Additional Billable Transactions",
                                      units: sum.toDouble(),
                                      price: plans[planId]
                                              ["pro_data_bill_amount"]
                                          .toDouble()),
                                  Detail(
                                      description:
                                          "Discounted Billable Transactions as per your current plan",
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
