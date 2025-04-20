import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

typedef StringCallback = void Function(String bio);

class BioView extends StatefulWidget {
  final VoidCallback onSkipped;
  final StringCallback onSave;
  final VoidCallback? onBacked;
  final VoidCallback? onPrevious;

  BioView(
      {required this.onSkipped,
      required this.onSave,
      this.onBacked,
      this.onPrevious});

  @override
  _BioViewState createState() => _BioViewState();
}

class _BioViewState extends State<BioView> {
  final GlobalKey<DoseFormState> _formKey = GlobalKey<DoseFormState>();
  final OutlineInputBorder textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0x0FFC7C7CC)),
  );
  String bio = '';
  final profanityDetector = ProfanityDetector();
  TextEditingController bioController = TextEditingController();
  FocusNode bioFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: BackButton(
              onPressed: () {
                if (widget.onBacked != null) {
                  widget.onBacked!();
                }
              },
            ),
            elevation: 0.5,
            title: Text(
              S.of(context).bio,
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, top: 0.0, bottom: 10.0),
                        child: Text(
                          S.of(context).bio_description,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      DoseForm(
                        formKey: _formKey,
                        child: Container(
                          height: 200,
                          child: DoseTextField(
                              isRequired: true,
                              controller: bioController,
                              focusNode: bioFocusNode,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                fillColor: Colors.grey[300],
                                filled: true,
                                hintText: S.of(context).bio_hint,
                                border: textFieldBorder,
                                enabledBorder: textFieldBorder,
                                focusedBorder: textFieldBorder,
                              ),
                              keyboardType: TextInputType.multiline,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              minLines: 6,
                              maxLines: null,
                              maxLength: 5000,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return S
                                      .of(context)
                                      .validation_error_bio_empty;
                                } else if (profanityDetector
                                    .isProfaneString(value)) {
                                  return S.of(context).profanity_text_alert;
                                } else if (value.length < 50) {
                                  this.bio = value;
                                  return S
                                      .of(context)
                                      .validation_error_bio_min_characters;
                                } else if (value.length > 5000) {
                                  this.bio = value;
                                  return S
                                      .of(context)
                                      .validation_error_bio_max_characters;
                                }
                                this.bio = value;
                                return null;
                              }),
                        ),
                      )
                    ],
                  ),
                ),
                // Spacer(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
                SizedBox(
                  width: 134,
                  child: CustomElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(bio);
                      }
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    textColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    elevation: 2.0,
                    child: Text(
                      S.of(context).next,
                      style: Theme.of(context).primaryTextTheme.labelLarge,
                    ),
                  ),
                ),
                CustomTextButton(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    widget.onSkipped();
                  },
                  child: Text(
                    AppConfig.prefs!.getBool(AppConfig.skip_bio) == null
                        ? S.of(context).skip
                        : S.of(context).cancel,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
