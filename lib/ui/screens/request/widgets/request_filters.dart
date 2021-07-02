import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_bloc.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/utils/extensions.dart';

/// [hideFilters] Pass bool to hide in order
/// Time Request
/// Money
/// Goods
/// One to many
/// Public
/// Virtual
class RequestFilters extends StatelessWidget {
  final Stream<RequestFilter> stream;
  final ValueChanged<RequestFilter> onTap;
  final List<bool> hideFilters;

  const RequestFilters({
    Key key,
    this.stream,
    @required this.onTap,
    this.hideFilters,
  })  : assert(hideFilters.length == 6),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestFilter>(
      initialData: RequestFilter(),
      stream: stream,
      builder: (context, snapshot) {
        var filter = snapshot.data;
        return Wrap(
          spacing: 8.0,
          children: [
            CustomChipExploreFilter(
              isHidden: hideFilters[0],
              label: 'Time',
              isSelected: filter.timeRequest,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    timeRequest: !snapshot.data.timeRequest,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters[1],
              label: 'Money',
              isSelected: filter.cashRequest,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    cashRequest: !snapshot.data.cashRequest,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters[2],
              label: 'Goods',
              isSelected: filter.goodsRequest,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    goodsRequest: !snapshot.data.goodsRequest,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters[3],
              label: S.of(context).one_to_many.sentenceCase(),
              isSelected: filter.oneToManyRequest,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    oneToManyRequest: !snapshot.data.oneToManyRequest,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters[4],
              label: 'Public',
              isSelected: filter.publicRequest,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    publicRequest: !snapshot.data.publicRequest,
                  ),
                );
              },
            ),
            CustomChipExploreFilter(
              isHidden: hideFilters[5],
              label: S.of(context).virtual,
              isSelected: filter.virtualRequest,
              onTap: () {
                onTap(
                  snapshot.data.copyWith(
                    virtualRequest: !snapshot.data.virtualRequest,
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
