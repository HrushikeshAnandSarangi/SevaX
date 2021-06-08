import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_list_bloc.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/utils/extensions.dart';

/// [hideFilters] Pass bool to hide in order
/// Time offer
/// Money
/// Goods
/// One to many
/// Pulic
/// Virtual
class OfferFilters extends StatelessWidget {
  final Stream<OfferFilter> stream;
  final ValueChanged<OfferFilter> onTap;
  final List<bool> hideFilters;

  const OfferFilters({Key key, this.stream, this.onTap, this.hideFilters})
      : assert(hideFilters.length == 6),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OfferFilter>(
      initialData: OfferFilter(),
      stream: stream,
      builder: (context, snapshot) {
        var filter = snapshot.data;
        return Wrap(
          spacing: 8.0,
          children: [
            CustomChipWithTap(
              isHidden: hideFilters[0],
              label: S.of(context).time,
              isSelected: filter.timeOffer,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    timeOffer: !snapshot.data.timeOffer,
                  ),
                );
              },
            ),
            CustomChipWithTap(
              isHidden: hideFilters[1],
              label: S.of(context).cash,
              isSelected: filter.cashOffer,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    cashOffer: !snapshot.data.cashOffer,
                  ),
                );
              },
            ),
            CustomChipWithTap(
              isHidden: hideFilters[2],
              label: S.of(context).goods,
              isSelected: filter.goodsOffer,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    goodsOffer: !snapshot.data.goodsOffer,
                  ),
                );
              },
            ),
            CustomChipWithTap(
              isHidden: hideFilters[3],
              label: S.of(context).one_to_many.sentenceCase(),
              isSelected: filter.oneToManyOffer,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    oneToManyOffer: !snapshot.data.oneToManyOffer,
                  ),
                );
              },
            ),
            CustomChipWithTap(
              isHidden: hideFilters[4],
              label: 'Public',
              isSelected: filter.publicOffer,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    publicOffer: !snapshot.data.publicOffer,
                  ),
                );
              },
            ),
            CustomChipWithTap(
              isHidden: hideFilters[5],
              label: S.of(context).virtual,
              isSelected: filter.virtualOffer,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    virtualOffer: !snapshot.data.virtualOffer,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
