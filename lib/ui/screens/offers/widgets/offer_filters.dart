import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_list_bloc.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/utils/extensions.dart';

import '../../../../labels.dart';

/// [hideFilters] Pass bool to hide in order
/// Time offer
/// Money
/// Goods
/// One to many
/// Pulic
/// Virtual
class OfferFilters extends StatelessWidget {
  final Stream<OfferFilter>? stream;
  final ValueChanged<OfferFilter>? onTap;
  final List<bool>? hideFilters;

  const OfferFilters({Key? key, this.stream, this.onTap, this.hideFilters})
      : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    assert(hideFilters!.length == 7);
    return StreamBuilder<OfferFilter>(
      stream: stream,
      builder: (context, snapshot) {
        var filter = snapshot.data ?? OfferFilter();
        return Wrap(
          spacing: 8.0,
          children: [
            CustomChipExploreFilter(
              isHidden: hideFilters![0],
              label: S.of(context).time,
              isSelected: filter!.timeOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    timeOffer: !snapshot.data!.timeOffer,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters![1],
              label: S.of(context).cash,
              isSelected: filter.cashOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    cashOffer: !snapshot.data!.cashOffer,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters![2],
              label: S.of(context).goods,
              isSelected: filter.goodsOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    goodsOffer: !snapshot.data!.goodsOffer,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters![3],
              label: S.of(context).one_to_many.sentenceCase(),
              isSelected: filter.oneToManyOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    oneToManyOffer: !snapshot.data!.oneToManyOffer,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters![4],
              label: S.of(context).public,
              isSelected: filter.publicOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    publicOffer: !snapshot.data!.publicOffer,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters![5],
              label: S.of(context).virtual,
              isSelected: filter.virtualOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    virtualOffer: !snapshot.data!.virtualOffer,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters![6],
              label: S.of(context).lending_text,
              isSelected: filter.lendingOffer,
              onTap: () {
                onTap!(
                  snapshot.data!.copyWith(
                    lendingOffer: !snapshot.data!.lendingOffer,
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
