import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_request/request_create_form.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:usage/uuid/uuid.dart';

class EditRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  String projectId;
  RequestModel requestModel;

  EditRequest({
    Key key,
    this.isOfferRequest,
    this.offer,
    this.timebankId,
    this.userModel,
    this.projectId,
    this.projectModel,
    @required this.requestModel,
  }) : super(key: key);

  @override
  _EditRequestState createState() => _EditRequestState();
}

class _EditRequestState extends State<EditRequest> {
  @override
  Widget build(BuildContext context) {
    logger.d("EDIT REQUEST  HASHCODE ${widget.requestModel.hashCode}");

    return ExitWithConfirmation(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              title,
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
                  logger.e('REQUESTMODEL CHECK:   ' + widget.requestModel.toString());
                  return RequestCreateForm(
                    formType: RequestFormType.EDIT,
                    requestModel: widget.requestModel,
                    isOfferRequest: widget.isOfferRequest,
                    offer: widget.offer,
                    timebankId: widget.timebankId,
                    userModel: widget.userModel,
                    loggedInUser: snapshot.data.loggedinuser,
                    projectId: widget.projectId,
                    projectModel: widget.projectModel,
                    comingFrom: ComingFrom.Requests,
                  );
                }
                return Text('');
              })),
    );
  }

  String get title {
    if (widget.requestModel.projectId == null ||
        widget.requestModel.projectId == "" ||
        widget.requestModel.projectId.isEmpty) {
      return S.of(context).edit;
    }
    return S.of(context).edit_request;
  }
}

/*
class ProjectSelection extends StatefulWidget {
  ProjectSelection({
    Key key,
    this.requestModel,
    this.admin,
    this.projectModelList,
    this.selectedProject,
    this.updateProjectIdCallback,
  }) : super(key: key);
  final admin;
  final List<ProjectModel> projectModelList;
  final ProjectModel selectedProject;
  RequestModel requestModel;
  Function(String projectId) updateProjectIdCallback;

  @override
  ProjectSelectionState createState() => ProjectSelectionState();
}

class ProjectSelectionState extends State<ProjectSelection> {
  ProjectModel selectedModel = ProjectModel();

  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return Container();
    }
    // log('Project Model Check:  ' + widget.projectModelList.toString());
    List<dynamic> list = [
      {"name": S.of(context).unassigned, "code": "None"}
    ];
    for (var i = 0; i < widget.projectModelList.length; i++) {
      list.add({
        "name": widget.projectModelList[i].name,
        "code": widget.projectModelList[i].id,
        "timebankproject": widget.projectModelList[i].mode == ProjectMode.TIMEBANK_PROJECT,
      });
    }
    // log('Model List:  ' + list.toString());
    // log('Project Id:  ' + widget.requestModel.projectId.toString());
    return MultiSelect(
      autovalidate: true,
      initialValue: [widget.selectedProject != null ? widget.selectedProject.id : 'None'],
      titleText: Row(
        children: [
          Text(S.of(context).assign_to_project),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.arrow_drop_down_circle,
            color: Theme.of(context).primaryColor,
            size: 30.0,
          )
        ],
      ),
      maxLength: 1,
      // optional
      hintText: S.of(context).tap_to_select,
      validator: (dynamic value) {
        if (value == null) {
          return S.of(context).assign_to_one_project;
        }
        return null;
      },
      errorText: S.of(context).assign_to_one_project,
      dataSource: list,
      admin: widget.admin,
      textField: 'name',
      valueField: 'code',
      filterable: true,
      required: true,
      titleTextColor: Colors.black,
      change: (value) {
        if (value != null && value[0] != 'None') {
          //widget.requestModel.projectId = value[0];
          logger.e('inside project selection widget 1: ' + value.toString());
          widget.updateProjectIdCallback(value[0]);
        } else {
          logger.e('inside project selection widget 2: ' + value.toString());
          widget.updateProjectIdCallback('None');
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }

//  void _onFormSaved() {
//    final FormState form = _formKey.currentState;
//    form.save();
//  }
}

typedef StringMapCallback = void Function(Map<String, dynamic> goods);

class GoodsDynamicSelection2 extends StatefulWidget {
  final bool automaticallyImplyLeading;
  Map<String, String> goodsbefore;
  final StringMapCallback onSelectedGoods;

  GoodsDynamicSelection2(
      {this.goodsbefore, @required this.onSelectedGoods, this.automaticallyImplyLeading = true});

  @override
  _GoodsDynamicSelection2State createState() => _GoodsDynamicSelection2State();
}

class _GoodsDynamicSelection2State extends State<GoodsDynamicSelection2> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();

  bool autovalidate = false;
  Map<String, String> goods = {};
  Map<String, String> _selectedGoods = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    this._selectedGoods = widget.goodsbefore != null ? widget.goodsbefore : {};
    CollectionRef.donationCategories.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.id);
        goods[data.id] = data['goodTitle'];

        // ids[data['name']] = data.id;
      });
      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            //TODOSUGGESTION
            TypeAheadField<SuggestedItem>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBuilder: (context, err) {
                  return Text(S.of(context).error_occured);
                },
                hideOnError: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: S.of(context).search,
                    filled: true,
                    fillColor: Colors.grey[300],
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    suffixIcon: InkWell(
                      splashColor: Colors.transparent,
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _textEditingController.clear();
                        controller.close();
                      },
                    ),
                  ),
                ),
                suggestionsBoxController: controller,
                suggestionsCallback: (pattern) async {
                  List<SuggestedItem> dataCopy = [];
                  goods.forEach(
                    (k, v) => dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.FROM_DB
                      ..suggesttionTitle = v),
                  );
                  dataCopy.retainWhere(
                      (s) => s.suggesttionTitle.toLowerCase().contains(pattern.toLowerCase()));
                  if (pattern.length > 2 &&
                      !dataCopy.contains(SuggestedItem()..suggesttionTitle = pattern)) {
                    var spellCheckResult = await SpellCheckManager.evaluateSpellingFor(pattern,
                        language: SevaCore.of(context).loggedInUser.language ?? 'en');
                    if (spellCheckResult.hasErros) {
                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.USER_DEFINED
                        ..suggesttionTitle = pattern);
                    } else if (spellCheckResult.correctSpelling != pattern) {
                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.SUGGESTED
                        ..suggesttionTitle = spellCheckResult.correctSpelling);

                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.USER_DEFINED
                        ..suggesttionTitle = pattern);
                    } else {
                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.USER_DEFINED
                        ..suggesttionTitle = pattern);
                    }
                  }
                  return await Future.value(dataCopy);
                },
                itemBuilder: (context, suggestedItem) {
                  switch (suggestedItem.suggestionMode) {
                    case SuggestionMode.FROM_DB:
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          suggestedItem.suggesttionTitle,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      );

                    case SuggestionMode.SUGGESTED:
                      if (ProfanityDetector().isProfaneString(suggestedItem.suggesttionTitle)) {
                        return ProfanityDetector.getProanityAdvisory(
                          suggestion: suggestedItem.suggesttionTitle,
                          suggestionMode: SuggestionMode.SUGGESTED,
                          context: context,
                        );
                      }
                      return searchUserDefinedEntity(
                        keyword: suggestedItem.suggesttionTitle,
                        language: 'en',
                        suggestionMode: suggestedItem.suggestionMode,
                        showLoader: true,
                      );

                    case SuggestionMode.USER_DEFINED:
                      if (ProfanityDetector().isProfaneString(suggestedItem.suggesttionTitle)) {
                        return ProfanityDetector.getProanityAdvisory(
                          suggestion: suggestedItem.suggesttionTitle,
                          suggestionMode: SuggestionMode.USER_DEFINED,
                          context: context,
                        );
                      }

                      return searchUserDefinedEntity(
                        keyword: suggestedItem.suggesttionTitle,
                        language: 'en',
                        suggestionMode: suggestedItem.suggestionMode,
                        showLoader: false,
                      );

                    default:
                      return Container();
                  }
                },
                noItemsFoundBuilder: (context) {
                  return searchUserDefinedEntity(
                    keyword: _textEditingController.text,
                    language: 'en',
                    showLoader: false,
                  );
                },
                onSuggestionSelected: (SuggestedItem suggestion) {
                  if (ProfanityDetector().isProfaneString(suggestion.suggesttionTitle)) {
                    return;
                  }

                  switch (suggestion.suggestionMode) {
                    case SuggestionMode.SUGGESTED:
                      var newGoodId = Uuid().generateV4();
                      addGoodsToDb(
                        goodsId: newGoodId,
                        goodsLanguage: 'en',
                        goodsTitle: suggestion.suggesttionTitle,
                      );
                      goods[newGoodId] = suggestion.suggesttionTitle;
                      break;

                    case SuggestionMode.USER_DEFINED:
                      var goodId = Uuid().generateV4();
                      addGoodsToDb(
                        goodsId: goodId,
                        goodsLanguage: 'en',
                        goodsTitle: suggestion.suggesttionTitle,
                      );
                      goods[goodId] = suggestion.suggesttionTitle;
                      break;

                    case SuggestionMode.FROM_DB:
                      break;
                  }
                  // controller.close();

                  _textEditingController.clear();
                  if (!_selectedGoods.containsValue(suggestion)) {
                    controller.close();
                    String id = goods.keys.firstWhere(
                      (k) => goods[k] == suggestion.suggesttionTitle,
                    );
                    _selectedGoods[id] = suggestion.suggesttionTitle;
                    widget.onSelectedGoods(_selectedGoods);
                    setState(() {});
                  }
                }
                // onSuggestionSelected: (suggestion) {
                //   _textEditingController.clear();
                //   if (!_selectedGoods.containsValue(suggestion)) {
                //     controller.close();
                //     String id =
                //         goods.keys.firstWhere((k) => goods[k] == suggestion);
                //     _selectedGoods[id] = suggestion;
                //     widget.onSelectedGoods(_selectedGoods);
                //     setState(() {});
                //   }
                // },
                ),

            SizedBox(height: 20),
            !isDataLoaded
                ? LoadingIndicator()
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Wrap(
                          runSpacing: 5.0,
                          spacing: 5.0,
                          children: _selectedGoods.values
                              .toList()
                              .map(
                                (value) => value == null
                                    ? Container()
                                    : CustomChip(
                                        title: value,
                                        onDelete: () {
                                          String id = _selectedGoods.keys.firstWhere(
                                            (k) {
                                              return _selectedGoods[k] == value;
                                            },
                                          );
                                          _selectedGoods.remove(id);
                                          widget.onSelectedGoods(_selectedGoods);
                                          setState(() {});
                                        },
                                      ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
            //   Spacer(),
          ],
        ));
  }

  FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
    String keyword,
    String language,
    SuggestionMode suggestionMode,
    bool showLoader,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showLoader ? getLinearLoading : LinearProgressIndicator();
        }

        return getSuggestionLayout(
          suggestion: keyword,
          suggestionMode: suggestionMode,
        );
      },
    );
  }

  Widget get getLinearLoading {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  static Future<void> addGoodsToDb({
    String goodsId,
    String goodsTitle,
    String goodsLanguage,
  }) async {
    await CollectionRef.donationCategories.doc(goodsId).set(
      {'goodTitle': goodsTitle, 'lang': goodsLanguage},
    );
  }

  Padding getSuggestionLayout({
    String suggestion,
    SuggestionMode suggestionMode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: S.of(context).add + ' ',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: "\"${suggestion}\"",
                            style: suggestionMode == SuggestionMode.SUGGESTED
                                ? TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  )
                                : TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red,
                                    decorationStyle: TextDecorationStyle.wavy,
                                    decorationThickness: 1.5,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      suggestionMode == SuggestionMode.SUGGESTED
                          ? S.of(context).suggested
                          : S.of(context).you_entered,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add,
                color: Colors.grey,
              ),
            ],
          )),
    );
  }
}
*/
