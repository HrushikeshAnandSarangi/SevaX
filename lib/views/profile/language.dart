import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/internationalization/applanguage.dart';

class LanguageListData {
  final languagelist = [
    LanguageModel(languageName: 'English', code: 'en'),
    LanguageModel(languageName: 'Portuguese', code: 'pt'),
    LanguageModel(languageName: 'French', code: 'fr'),
    LanguageModel(languageName: 'Spanish', code: 'es'),
    LanguageModel(languageName: 'Chinese Simplified', code: 'zh-CN')
  ];
  LanguageListData();
  getData() {
    return languagelist;
  }

  LanguageModel getLanguageSupported(String languagecode) {
    print(languagecode);
    var found = -1;
    for (var i = 0; i < this.languagelist.length; i++) {
      if (this.languagelist[i].code == languagecode) {
        found = i;
        break;
      }
    }
    if (found > -1) {
      return this.languagelist[found];
    } else {
      return LanguageModel(languageName: 'English', code: 'en');
    }
  }
}

class LanguageView extends StatefulWidget {
  @override
  _LanguageViewState createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('settings', 'language'),
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: LanguageList());
  }
}

class LanguageList extends StatefulWidget {
  @override
  LanguageListState createState() => LanguageListState();
}

class LanguageListState extends State<LanguageList> {
  List<LanguageModel> languagelist = [];
  String isSelected;
//  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    languagelist = new LanguageListData().getData();
    languagelist.sort((a, b) {
      return a.languageName
          .toLowerCase()
          .compareTo(b.languageName.toLowerCase());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    return StreamBuilder<Object>(
        stream: FirestoreManager.getUserForIdStream(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel userModel = snapshot.data;
          isSelected = userModel.language;
          return ListView.builder(
            itemCount: languagelist.length,
//            controller: _scrollController,
            itemBuilder: (context, index) {
              LanguageModel model = languagelist.elementAt(index);
              return Card(
                child: ListTile(
                  leading: getIcon(isSelected, model.code),
                  trailing: Text(
                    '${model.languageName}',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  title: Text('${model.languageName}'),
                  subtitle: Text('${model.code}'),
                  onTap: () async {
                    if (userModel.language != model.code) {
                      print(model.code);
                      appLanguage.changeLanguage(Locale(model.code));
                      userModel.language = model.code;
                      await updateUserLanguage(user: userModel);
                    }
                  },
                ),
              );
            },
          );
        });
  }

  Widget getIcon(String isSelected, String userTimezone) {
    if (isSelected == userTimezone) {
//      print("inside if card");
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Icon(
          Icons.done,
          color: Colors.green,
          size: 28,
        ),
      );
    } else {
      return null;
    }
  }
}

class LanguageModel {
  String languageName;
  String code;
  LanguageModel({this.languageName, this.code});
}
