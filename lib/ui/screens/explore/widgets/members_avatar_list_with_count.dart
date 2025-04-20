import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/views/core.dart';

class MemberAvatarListWithCount extends StatelessWidget {
  final List<String>? userIds;
  final double? radius;

  const MemberAvatarListWithCount({Key? key, this.userIds, this.radius})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Provider.of<MembersBloc>(context).getUserImages(
          (userIds?.length ?? 0) > 5
              ? userIds?.sublist(0, 5) ?? []
              : userIds ?? [],
          isUserSignedIn: SevaCore.of(context) != null),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            height: 2 * (radius ?? 12.0),
          );
        }
        return Row(
          children: [
            ...List.generate(
              snapshot.data?.length ?? 0,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: radius ?? 12,
                  backgroundImage: NetworkImage(
                    snapshot.data![index] ?? defaultUserImageURL,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
            Text('${userIds?.length ?? 0} ${S.of(context).members}'),
          ],
        );
      },
    );
  }
}
