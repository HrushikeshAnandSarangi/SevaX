import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/views/community/constants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CreateCommunity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateCommunityState();
  }
}

class CreateCommunityState extends State<CreateCommunity> {
  var scollContainer = ScrollController();
  PanelController _pc = new PanelController();
  BillingDetailsModel billingDetails = BillingDetailsModel();
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  GlobalKey<FormState> _stateSelectorKey = GlobalKey();

  String selectedCountryValue = "Select your country";

  var stateFocus = FocusNode();
  var pincodeFocus = FocusNode();
  var companyNameFocus = FocusNode();
  var streetAddressFocus = FocusNode();
  var additionalNotesFocus = FocusNode();
  var streetAddressTwoFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SlidingUpPanelExample"),
      ),
      body: SlidingUpPanel(
        minHeight: 0,
        maxHeight: 280,
        color: Colors.white,
        parallaxEnabled: true,
        controller: _pc,
        panel: _scrollingList(),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Open"),
            onPressed: () {
              scrollToTop();

              _pc.open();
            },
          ),
          RaisedButton(
            child: Text("Close"),
            onPressed: () => _pc.close(),
          ),
        ],
      ),
    );
  }

  Widget get _widgetCountrySelector {
    // var countryList = CommunityConstants.COUNTRY_LIST;
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: Colors.green,
          style: BorderStyle.solid,
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.fromLTRB(12, 12, 10, 5),
      alignment: Alignment.center,
      width: double.infinity,
      child: new DropdownButton<String>(
        key: _stateSelectorKey,
        items: CommunityConstants.COUNTRY_LIST.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        // isExpanded: true,
        // validator: (val) {
        //   // return "lkaknnsndlkns";
        //   // return billingDetails.countryName == "Select your country"
        //   //     // ? "Please select your country"
        //   //     ? "null"
        //   //     : "null";
        // },
        hint: Text(selectedCountryValue),
        onChanged: (value) {
          selectedCountryValue = value;
          billingDetails.countryName = value;
          setState(() {
            print(selectedCountryValue);
          });
        },
      ),
    );
  }

  Widget get _stateWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          FocusScope.of(context).requestFocus(pincodeFocus);
        },
        onChanged: (value) {
          billingDetails.stateName = value;
        },
        initialValue:
            billingDetails.stateName != null ? billingDetails.stateName : '',
        validator: BillingDetailsModel.billingValidator,
        focusNode: stateFocus,
        textInputAction: TextInputAction.next,
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "State",
        ),
      ),
    );
  }

  Widget get _pinCodeWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
          validator: BillingDetailsModel.billingValidator,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(streetAddressFocus);
          },
          onChanged: (value) {
            billingDetails.pinCode = value;
          },
          initialValue:
              billingDetails.pinCode != null ? billingDetails.pinCode : '',
          focusNode: pincodeFocus,
          textInputAction: TextInputAction.next,
          decoration: BillingDetailsModel.getInputDecoration(
            fieldTitle: "Pincode",
          )),
    );
  }

  Widget get _additionalNotesWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          scrollToBottom();
        },
        onChanged: (value) {
          billingDetails.additionalNotes = value;
        },
        initialValue: billingDetails.additionalNotes != null
            ? billingDetails.additionalNotes
            : '',
        validator: BillingDetailsModel.billingValidator,
        focusNode: additionalNotesFocus,
        textInputAction: TextInputAction.next,
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "Additional Notes",
        ),
      ),
    );
  }

  InputDecoration getData(String fieldValue) {
    return new InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 5.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
      ),
      border: OutlineInputBorder(
        gapPadding: 0.0,
        borderRadius: BorderRadius.circular(1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
      ),
      hintText: fieldValue,
      alignLabelWithHint: false,
    );
  }

  Widget get _companyNameWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          FocusScope.of(context).requestFocus(additionalNotesFocus);
        },
        onChanged: (value) {
          billingDetails.companyName = value;
        },
        initialValue: billingDetails.companyName != null
            ? billingDetails.companyName
            : '',
        validator: BillingDetailsModel.billingValidator,
        focusNode: companyNameFocus,
        textInputAction: TextInputAction.next,
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "Company Name",
        ),
      ),
    );
  }

  Widget get _billingDetailsTitle {
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Text(
          'Billing Details',
          style: TextStyle(
              color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget get _streetAddressWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          FocusScope.of(context).requestFocus(streetAddressTwoFocus);
        },
        onChanged: (value) {
          billingDetails.streetAddressOne = value;
        },
        validator: BillingDetailsModel.billingValidator,
        focusNode: streetAddressFocus,
        textInputAction: TextInputAction.next,
        initialValue: billingDetails.streetAddressOne != null
            ? billingDetails.streetAddressOne
            : '',
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "Street Address 1",
        ),
      ),
    );
  }

  Widget get _streetAddressTwoWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(companyNameFocus);
          },
          onChanged: (value) {
            billingDetails.streetAddressTwo = value;
          },
          validator: BillingDetailsModel.billingValidator,
          focusNode: streetAddressTwoFocus,
          textInputAction: TextInputAction.next,
          initialValue: billingDetails.streetAddressTwo != null
              ? billingDetails.streetAddressTwo
              : '',
          decoration: BillingDetailsModel.getInputDecoration(
            fieldTitle: "Street Address 2",
          )),
    );
  }

  Widget get _continueBtn {
    return Container(
      margin: EdgeInsets.all(10),
      child: RaisedButton(
        child: Text("Continue"),
        color: Colors.orange,
        onPressed: () {
          if (_billingInformationKey.currentState.validate()) {
            if (billingDetails.countryName == null) {
              scrollToTop();
            } else {
              print("All Good");
              _pc.hide();
            }
          }
          print("Here are the billing details $billingDetails");
          // _pc.close();
        },
      ),
    );
  }

  Widget _scrollingList() {
    return Container(
        // var scrollController = Sc
        //adding a margin to the top leaves an area where the user can swipe
        //to open/close the sliding panel
        margin: const EdgeInsets.only(top: 36.0),
        color: Colors.white,
        child: Form(
          key: _billingInformationKey,
          child: ListView(
            controller: scollContainer,
            children: <Widget>[
              _billingDetailsTitle,
              _widgetCountrySelector,
              _stateWidget,
              _pinCodeWidget,
              _streetAddressWidget,
              _streetAddressTwoWidget,
              _companyNameWidget,
              _additionalNotesWidget,
              _continueBtn,
            ],
          ),
        ));
  }

  void scrollToTop() {
    scollContainer.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scollContainer.animateTo(
      scollContainer.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class BillingDetailsModel {
  String countryName;
  String stateName;
  String pinCode;
  String streetAddressOne;
  String streetAddressTwo;
  String companyName;
  String additionalNotes;

  @override
  String toString() {
    return "Billing information provided : {countryName : $countryName, stateName : $stateName, pincode : $pinCode, streetAddressOne : $streetAddressOne, streetAddressTwo : $streetAddressTwo, companyName  : $companyName, additionalNotes : $additionalNotes }";
  }

  static String billingValidator(String value) {
    return value.isEmpty ? 'Field cannot be left blank' : null;
  }

  static InputDecoration getInputDecoration({String fieldTitle}) {
    return InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 2.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
      ),
      border: OutlineInputBorder(
          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
      ),
      hintText: fieldTitle,
      alignLabelWithHint: false,
    );
  }
}
