import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunitiesCategory extends StatelessWidget {
  final Stream<List<CommunityCategoryModel>>? stream;
  final ValueChanged<CommunityCategoryModel> onTap;

  const CommunitiesCategory({Key? key, this.stream, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: StreamBuilder<List<CommunityCategoryModel>>(
        stream: stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<CommunityCategoryModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }
          if (snapshot.data == null) {
            return Center(
              child: Text(S.of(context).no_categories_available),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => SimpleCommunityCard(
                image: snapshot.data?[index].logo ??
                    'https://media.istockphoto.com/photos/group-portrait-of-a-creative-business-team-standing-outdoors-three-picture-id1146473249?k=6&m=1146473249&s=612x612&w=0&h=W1xeAt6XW3evkprjdS4mKWWtmCVjYJnmp-LHvQstitU=',
                onTap: () => onTap(snapshot.data![index]),
                title: snapshot.data?[index].getCategoryName(
                      context,
                    ) ??
                    '',
              ),
            ),
          );
        },
      ),
    );
  }
}
