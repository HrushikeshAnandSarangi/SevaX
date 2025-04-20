import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/goods_display_page.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';

class DonationParticipantCard extends StatelessWidget {
  final String photoUrl;
  final String type;
  final String name;
  final int timestamp;
  final bool isCashDonation;
  final List<String> goods;
  final String amount;
  final String currency;
  final String comments;
  final DonationStatus status;

  final Widget child;

  const DonationParticipantCard({
    Key? key,
    required this.photoUrl,
    required this.type,
    required this.name,
    required this.isCashDonation,
    required this.timestamp,
    required this.goods,
    required this.amount,
    required this.currency,
    required this.child,
    required this.comments,
    required this.status,
  })  : assert(name != null),
        assert(isCashDonation != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isCashDonation
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GoodsDisplayPage(
                    label: status == DonationStatus.REQUESTED
                        ? S.of(context).donations_received.replaceAll('s', '')
                        : this.type == 'request'
                            ? S
                                .of(context)
                                .donations_received
                                .replaceAll('s', '')
                            : S.of(context).donation_offered,
                    name: name,
                    photoUrl: photoUrl,
                    goods: goods,
                    message: comments ?? '',
                  ),
                ),
              );
            },
      child: Row(
        children: [
          CustomNetworkImage(
            photoUrl,
            entityName: name,
            size: 50,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timestamp != null
                      ? DateFormat('MMMd').format(
                          DateTime.fromMillisecondsSinceEpoch(timestamp),
                        )
                      : '',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          child ??
              Text(
                isCashDonation
                    ? '$currency $amount'
                    : '${goods.length} ${S.of(context).items}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
        ],
      ),
    );
  }
}
