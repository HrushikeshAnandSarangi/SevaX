import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/models/models.dart';

Future<NewsModel> fetchPosts({String? url, NewsModel? newsObject}) async {
  var response;
  try {
    response = await http.get(
      Uri.parse(url!),
    );
  } catch (e) {
    return newsObject!;
  }

  if (response.statusCode != 200) {
    return newsObject!;
  }

  var document = parse(response.body);

  var images = document.getElementsByTagName("img");

  var imagesList = [];

  images
      .map((element) => {
            if (element.attributes['src'] != null &&
                element.attributes['src']!.contains("http"))
              {
                imagesList.add(element.attributes['src']!),
              }
          })
      .toList();

  if (imagesList.length > 1) {
    ;
    newsObject!.imageScraped = imagesList[imagesList.length ~/ 2];
  } else if (imagesList.length > 0) {
    ;
    newsObject!.imageScraped = imagesList[0];
  } else {
    ;
    newsObject!.imageScraped = "NoData";
  }

  var links = document.querySelectorAll('title');
  for (var link in links) {
    if (link.text != null) {
      newsObject.title = link.text;
      break;
    }
  }

  var para = document.querySelectorAll('p');

  for (var link in para) {
    if (link.text != null) {
      if (newsObject.description == null) {
        newsObject.description = link.text.trim();
      } else if (newsObject.description!.length < link.text.length)
        newsObject.description = link.text.trim();
      else {
        newsObject.description =
            newsObject.description! + "\n" + link.text.trim();
      }
    }
  }

  return newsObject;
}
