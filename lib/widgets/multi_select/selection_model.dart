import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class SelectionModal extends StatefulWidget {
  @override
  _SelectionModalState createState() => _SelectionModalState();
  final List dataSource;
  final bool admin;
  final List values;
  final bool filterable;
  final String textField;
  final String valueField;
  final Widget title;
  final int maxLength;
  final Color buttonBarColor;
  final String cancelButtonText;
  final IconData cancelButtonIcon;
  final Color cancelButtonColor;
  final Color cancelButtonTextColor;
  final String saveButtonText;
  final IconData saveButtonIcon;
  final Color saveButtonColor;
  final Color saveButtonTextColor;
  final String deleteButtonTooltipText;
  final IconData deleteIcon;
  final Color deleteIconColor;
  final Color selectedOptionsBoxColor;
  final String selectedOptionsInfoText;
  final Color selectedOptionsInfoTextColor;
  final IconData checkedIcon;
  final IconData uncheckedIcon;
  final Color checkBoxColor;
  final Color searchBoxColor;
  final String searchBoxHintText;
  final Color searchBoxFillColor;
  final IconData searchBoxIcon;
  final String searchBoxToolTipText;
  SelectionModal(
      {this.filterable,
      this.dataSource,
      this.admin,
      this.title,
      this.values,
      this.textField,
      this.valueField,
      this.maxLength,
      this.buttonBarColor,
      this.cancelButtonText,
      this.cancelButtonIcon,
      this.cancelButtonColor,
      this.cancelButtonTextColor,
      this.saveButtonText,
      this.saveButtonIcon,
      this.saveButtonColor,
      this.saveButtonTextColor,
      this.deleteButtonTooltipText,
      this.deleteIcon,
      this.deleteIconColor,
      this.selectedOptionsBoxColor,
      this.selectedOptionsInfoText,
      this.selectedOptionsInfoTextColor,
      this.checkedIcon,
      this.uncheckedIcon,
      this.checkBoxColor,
      this.searchBoxColor,
      this.searchBoxHintText,
      this.searchBoxFillColor,
      this.searchBoxIcon,
      this.searchBoxToolTipText})
      : super();
}

class _SelectionModalState extends State<SelectionModal> {
  RequestModel requestModel;
  int sharedValue = 0;
  final globalKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  bool _isSearching;

  List _localDataSourceWithState = [];
  List _searchresult = [];

  _SelectionModalState() {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _isSearching = false;
        });
      } else {
        setState(() {
          _isSearching = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    requestModel = RequestModel(communityId: '');
    requestModel.requestMode = widget.admin
        ? RequestMode.TIMEBANK_REQUEST
        : RequestMode.PERSONAL_REQUEST;
    widget.dataSource.forEach((item) {
      var newItem = {
        'value': item[widget.valueField],
        'text': item[widget.textField],
        'checked': widget.values.contains(item[widget.valueField])
      };
      _localDataSourceWithState.add(newItem);
    });

    _searchresult = List.from(_localDataSourceWithState);
    _isSearching = false;
    filterProjects();
  }

  void filterProjects() {
    _localDataSourceWithState = [];
    widget.dataSource.forEach((item) {
      var newItem = {
        'value': item[widget.valueField],
        'text': item[widget.textField],
        'checked': widget.values.contains(item[widget.valueField])
      };
      if (widget.admin) {
        if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
          if (item['timebankproject'] != null && item['timebankproject']) {
            _localDataSourceWithState.add(newItem);
          } else if (item['timebankproject'] == null) {
            _localDataSourceWithState.add(newItem);
          }
        } else {
          if (!(item['timebankproject'] != null && item['timebankproject'])) {
            _localDataSourceWithState.add(newItem);
          } else if (item['timebankproject'] == null) {
            _localDataSourceWithState.add(newItem);
          }
        }
      } else {
        if (!(item['timebankproject'] != null && item['timebankproject'])) {
          _localDataSourceWithState.add(newItem);
        } else if (item['timebankproject'] == null) {
          _localDataSourceWithState.add(newItem);
        }
      }
    });
    _searchresult = List.from(_localDataSourceWithState);
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      leading: null,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      centerTitle: false,
      title:
          widget.title, //Text(widget.title, style: TextStyle(fontSize: 18.0)),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            size: 26.0,
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          widget.filterable ? _buildSearchText() : SizedBox(),
          Expanded(
            child: _optionsList(),
          ),
          _currentlySelectedOptions(),
          Container(
            color: widget.buttonBarColor ?? Colors.grey.shade100,
            child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CustomElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    child: Text(
                      S.of(context).cancel,
                      style: Theme.of(context).primaryTextTheme.button,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      widget.saveButtonIcon ?? Icons.save,
                      size: 20.0,
                    ),
                    onPressed: _localDataSourceWithState
                                .where((item) => item['checked'])
                                .length >
                            widget.maxLength
                        ? null
                        : () {
                            var selectedValuesObjectList =
                                _localDataSourceWithState
                                    .where((item) => item['checked'])
                                    .toList();
                            var selectedValues = [];
                            selectedValuesObjectList.forEach((item) {
                              selectedValues.add(item['value']);
                            });
                            Navigator.pop(context, selectedValues);
                          },
                    style: ElevatedButton.styleFrom(
                      primary: widget.saveButtonColor ??
                          Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      widget.saveButtonText ?? S.of(context).done,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .button
                          .merge(TextStyle(
                            color: widget.saveButtonTextColor ?? Colors.white,
                          )),
                    ),
                  )
                ]),
          )
        ],
      ),
    );
  }

  Widget _currentlySelectedOptions() {
    List<Widget> selectedOptions = [];

    var selectedValuesObjectList =
        _localDataSourceWithState.where((item) => item['checked']).toList();
    var selectedValues = [];
    selectedValuesObjectList.forEach((item) {
      selectedValues.add(item['value']);
    });
    selectedValues.forEach((item) {
      var existingItem = _localDataSourceWithState
          .singleWhere((itm) => itm['value'] == item, orElse: () => null);
      selectedOptions.add(Chip(
        label: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 80.0),
          child: Text(existingItem['text'], overflow: TextOverflow.ellipsis),
        ),
        deleteButtonTooltipMessage:
            widget.deleteButtonTooltipText ?? S.of(context).tap_to_delete,
        deleteIcon: widget.deleteIcon ?? Icon(Icons.cancel),
        deleteIconColor: widget.deleteIconColor ?? Colors.grey,
        onDeleted: () {
          existingItem['checked'] = false;
          setState(() {});
        },
      ));
    });
    return selectedOptions.length > 0
        ? Container(
            padding: EdgeInsets.all(10.0),
            color: widget.selectedOptionsBoxColor ?? Colors.grey.shade400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  widget.selectedOptionsInfoText ??
                      '${S.of(context).currently_selected} ${selectedOptions.length}  ${S.of(context).tap_to_remove_tooltip}', // use languageService here
                  style: TextStyle(
                      color:
                          widget.selectedOptionsInfoTextColor ?? Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 8,
                    ),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                          child: Wrap(
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 0.4, // gap between lines
                        alignment: WrapAlignment.start,
                        children: selectedOptions,
                      )),
                    )),
              ],
            ),
          )
        : Container();
  }

  ListView _optionsList() {
    List<Widget> options = [];
    _searchresult.forEach((item) {
      options.add(ListTile(
          title: Text(item['text'] ?? ''),
          leading: Transform.scale(
            child: Icon(
                item['checked']
                    ? widget.checkedIcon ?? Icons.check_box
                    : widget.uncheckedIcon ?? Icons.check_box_outline_blank,
                color: widget.checkBoxColor ?? Theme.of(context).primaryColor),
            scale: 1.5,
          ),
          onTap: () {
            _searchresult.forEach((f) => f['checked'] = false);
            item['checked'] = !item['checked'];
            setState(() {});
          }));
      options.add(Divider(height: 1.0));
    });
    return ListView(children: options);
  }

  Widget requestSwitch() {
    if (widget.admin) {
      return Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          width: double.infinity,
          child: CupertinoSegmentedControl<int>(
            selectedColor: Theme.of(context).primaryColor,
            children: {
              0: Text(
                S.of(context).seva_community_events,
                style: TextStyle(fontSize: 12.0),
              ),
              1: Text(
                S.of(context).personal_events,
                style: TextStyle(fontSize: 12.0),
              ),
            },
            borderColor: Colors.grey,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            groupValue: sharedValue,
            onValueChanged: (int val) {
              if (val != sharedValue) {
                setState(() {
                  if (val == 0) {
                    requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
                  } else {
                    requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
                  }
                  filterProjects();
                  sharedValue = val;
                });
              }
            },
            //groupValue: sharedValue,
          ));
    } else {
      return Container();
    }
  }

  Widget _buildSearchText() {
    return Container(
//      color: widget.searchBoxColor ?? Theme.of(context).primaryColor,
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // requestSwitch(),
              TextField(
                controller: _controller,
                keyboardAppearance: Brightness.light,
                onChanged: searchOperation,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(6.0),
                    ),
                  ),
                  filled: true,
                  hintText:
                      widget.searchBoxHintText ?? "${S.of(context).search}...",
                  fillColor: widget.searchBoxFillColor ?? Colors.white,
                  suffix: SizedBox(
                    height: 15.0,
                    child: IconButton(
                      padding: EdgeInsets.only(top: 8),
                      icon: widget.searchBoxIcon ?? Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        searchOperation('');
                      },
                      tooltip:
                          widget.searchBoxToolTipText ?? S.of(context).clear,
                    ),
                  ),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  void searchOperation(String searchText) {
    _searchresult.clear();
    if (_isSearching != null &&
        searchText != null &&
        searchText.toString().trim() != '') {
      for (int i = 0; i < _localDataSourceWithState.length; i++) {
        String data =
            '${_localDataSourceWithState[i]['value']} ${_localDataSourceWithState[i]['text']}';
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          _searchresult.add(_localDataSourceWithState[i]);
        }
      }
    } else {
      _searchresult = List.from(_localDataSourceWithState);
    }
  }
}
