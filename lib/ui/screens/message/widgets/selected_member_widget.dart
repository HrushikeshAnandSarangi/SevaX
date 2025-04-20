import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class SelectedMemberWidget extends StatelessWidget {
  final TimebankModel? timebankModel;
  final ParticipantInfo? info;
  final VoidCallback? onRemovePressed;
  final bool? isEditable;

  const SelectedMemberWidget(
      {Key? key,
      this.timebankModel,
      this.info,
      this.onRemovePressed,
      this.isEditable = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return (info == null ||
            (timebankModel != null
                ? !timebankModel!.members.contains(info!.id!)
                : false))
        ? Container(
            width: 0,
            height: 0,
          )
        : Container(
            width: 75,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      child: CustomNetworkImage(
                        info?.photoUrl ?? defaultUserImageURL,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Offstage(
                      offstage: !isEditable!,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: GestureDetector(
                            onTap: onRemovePressed,
                            child: Icon(
                              Icons.cancel,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(info!.name == null ? '' : info!.name!,
                    textAlign: TextAlign.center),
              ],
            ),
          );
  }
}
