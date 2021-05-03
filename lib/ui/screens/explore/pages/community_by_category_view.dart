import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunityByCategoryView extends StatefulWidget {
  final CommunityCategoryModel model;

  const CommunityByCategoryView({
    Key key,
    @required this.model,
  }) : super(key: key);
  @override
  _CommunityByCategoryViewState createState() =>
      _CommunityByCategoryViewState();
}

class _CommunityByCategoryViewState extends State<CommunityByCategoryView> {
  Future<List<CommunityModel>> communities;

  @override
  void initState() {
    communities = ElasticSearchApi.getCommunitiesByCategory(widget.model.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExplorePageViewHolder(
      hideSearchBar: true,
      hideHeader: Provider.of<UserModel>(context, listen: false) != null,
      hideFooter: Provider.of<UserModel>(context, listen: false) != null,
      appBarTitle: widget.model.getCategoryName(context),
      child: FutureBuilder(
        future: communities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4),
                child: LoadingIndicator(),
              ),
            );
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4 - 20),
                child: Text('No result found'),
              ),
            );
          }

          int length = snapshot.data.length;
          return Column(
            children: List.generate(
              length,
              (index) {
                return ExploreCommunityCard(
                  model: snapshot.data[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
