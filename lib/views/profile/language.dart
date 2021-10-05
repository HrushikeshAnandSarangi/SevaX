import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

Map<String, String> languageNames = {
  'en': 'English',
  'pt': 'Portuguese',
  'fr': 'French',
  'es': 'Spanish',
  'af': 'Afrikaans',
  'sw': 'Swahili',
  // 'sn': 'Shona',
  'zh_CN': 'Chinese Simplified',
  'zh_TW': 'Chinese Traditional',
};

class LanguageView extends StatefulWidget {
  @override
  _LanguageViewState createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).my_language,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: LanguageList(),
    );
  }
}

class LanguageList extends StatefulWidget {
  @override
  LanguageListState createState() => LanguageListState();
}

class LanguageListState extends State<LanguageList> {
  List<LanguageModel> languagelist = [];
  String isSelected;
//  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    //make sure supported lang and the languageNames on this screen are synced
    // assert(languageNames.length != S.delegate.supportedLocales.length
    //     );
    languageNames.forEach((key, value) {
      languagelist.add(
        LanguageModel(
          languageName: value,
          locale: getLocaleFromCode(key),
        ),
      );
    });

    languagelist.sort(
      (a, b) =>
          a.languageName.toLowerCase().compareTo(b.languageName.toLowerCase()),
    );
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
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        UserModel userModel = snapshot.data;
        return ListView.builder(
          itemCount: languagelist.length,
//            controller: _scrollController,
          itemBuilder: (context, index) {
            LanguageModel model = languagelist.elementAt(index);
            return Card(
              child: ListTile(
                leading: getIcon(
                  model.locale == getLocaleFromCode(userModel.language),
                ),
                trailing: Text(
                  '${model.languageName}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                title: Text('${model.languageName}'),
                subtitle: Text(getCodeFromLocale(model.locale)),
                onTap: () async {
                  if (userModel.language != getCodeFromLocale(model.locale)) {
                    appLanguage.changeLanguage(model.locale);
                    userModel.language = getCodeFromLocale(model.locale);
                    await updateUserLanguage(user: userModel);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget getIcon(bool isSelected) {
    return isSelected
        ? Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              Icons.done,
              color: Colors.green,
              size: 28,
            ),
          )
        : null;
  }
}

class LanguageModel {
  String languageName;
  Locale locale;
  LanguageModel({this.languageName, this.locale});
}

//For generating locale for langCode_countryCode
Locale getLocaleFromCode(String code) {
  String country;
  String langCode;
  if (code.contains('_')) {
    List<String> data = code.split('_');
    langCode = data[0];
    country = data[1];
  } else {
    langCode = code;
    country = null;
  }
  return Locale.fromSubtags(languageCode: langCode, countryCode: country);
}

String getCodeFromLocale(Locale locale) {
  if (locale.countryCode != null) {
    return '${locale.languageCode}_${locale.countryCode}';
  } else {
    return '${locale.languageCode}';
  }
}
