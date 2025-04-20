import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class SevaCoinWidget extends StatelessWidget {
  final double? amount;
  final VoidCallback? onTap;

  const SevaCoinWidget({Key? key, this.amount, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
      child: CustomElevatedButton(
        shape: StadiumBorder(),
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16),
        elevation: 2.0,
        textColor: Colors.black,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: sevaCoinIcon(),
                ),
                SizedBox(height: 1),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: sevaCoinIcon(),
                ),
                SizedBox(height: 1),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: sevaCoinIcon(),
                ),
              ],
            ),
            SizedBox(width: 5),
            Text(
              '${amount != null ? double.parse(amount!.toStringAsFixed(2)) : 0} ${AppConfig.isTestCommunity ? S.of(context).seva_credits : S.of(context).seva_credits}',
              style: TextStyle(
                color: amount! > 0 ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        onPressed: onTap ?? () {},
      ),
    );
  }

  Widget sevaCoinIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(2),
        ),
        color: Color.fromARGB(255, 255, 197, 75),
      ),
      width: 20,
      height: 5,
    );
  }
}
