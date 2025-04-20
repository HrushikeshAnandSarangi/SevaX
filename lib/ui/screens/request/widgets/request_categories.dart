import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_browse_card.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class RequestCategories extends StatelessWidget {
  final Stream<List<CategoryModel>>? stream;
  final ValueChanged<CategoryModel>? onTap;

  const RequestCategories({Key? key, this.stream, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.data == null) {
          return Center(
            child: Text(S.of(context).no_categories_available),
          );
        }
        return GridView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 1,
            crossAxisSpacing: 0.5,
            childAspectRatio: 6,
          ),
          children: List.generate(
            snapshot.data!.length,
            (index) => ExploreBrowseCard(
              imageUrl: snapshot.data![index].logo ??
                  'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore%20browse%20card%20image.JPG?alt=media&token=48eda7bf-0089-40f4-8b04-0efcb3a881bd',
              title: snapshot.data![index].getCategoryName(context),
              onTap: () => onTap!(snapshot.data![index]),
            ),
          ),
        );
      },
    );
  }
}
