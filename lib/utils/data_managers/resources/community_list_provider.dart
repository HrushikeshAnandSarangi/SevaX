import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:sevaexchange/models/community_model.dart';

class CommunityApiProvider {
  Client client = Client();
//  Future<CategoryListModel> fetchCategoryList() async {
//    Response response;
//    if(_apiKey != 'api-key') {
//       response = await client.get("$_baseUrl/popular?api_key=$_apiKey");
//    }else{
//      throw Exception('Please add your API key');
//    }
//    if (response.statusCode == 200) {
//      // If the call to the server was successful, parse the JSON
//      return CategoryListModel.fromJson(json.decode(response.body));
//    } else {
//      // If that call was not successful, throw an error.
//      throw Exception('Failed to load post');
//    }
//  }


  Future<CommunityListModel> searchCommunityByName(String name,CommunityListModel communities) async {
    communities.removeall();
    if (name.isNotEmpty && name.length > 4) {
      await Firestore.instance
          .collection('communities')
          .where('name', isEqualTo: name)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
          var community = CommunityModel.fromMap(documentSnapshot.data);
          communities.add(community);
        });
      });
    }
    return communities;
  }
}
