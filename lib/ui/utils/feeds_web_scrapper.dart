import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class FeedsWebScraperError implements Exception {
  final String message;
  FeedsWebScraperError(this.message);

  @override
  String toString() {
    return message;
  }
}

class FeedWebScraperData {
  final String? title;
  final String? subtitle;
  final String? image;
  final String? body;
  final String? link;

  FeedWebScraperData({
    this.title,
    this.subtitle,
    this.image,
    this.body,
    this.link,
  });

  @override
  String toString() {
    return '$title \n\n $subtitle \n\n $image \n\n $body \n\n $link';
  }
}

class FeedsWebScraper {
  final String url;
  late http.Response _response;
  static String _title = 'og:title';
  static String _description = 'og:description';
  static String _image = 'og:image';
  static String _siteName = 'og:site_name';

  FeedsWebScraper({required this.url});

  Future<bool> loadData() async {
    try {
      _response = await http.get(Uri.parse(url));
      return true;
    } catch (e) {
      throw FeedsWebScraperError(e.toString());
    }
  }

  FeedWebScraperData getScrapedData() {
    if (_response == null) {
      throw FeedsWebScraperError('call loadData first');
    }
    if (_response.statusCode == 200) {
      Document document = parse(_response.body);

      return FeedWebScraperData(
        title: _getMetaData(document, _title),
        subtitle: _getMetaData(document, _description),
        image: _getMetaData(document, _image),
        link: _getMetaData(document, _siteName),
        body: _getParagraphs(document),
      );
    } else {
      throw FeedsWebScraperError(
          'Something went wrong ${_response.statusCode}');
    }
  }

  String _getMetaData(Document document, String tag) {
    var metaTag = document.getElementsByTagName("meta").firstWhere(
          (meta) => meta.attributes['property'] == tag,
          orElse: () => Element.tag('meta'),
        );
    return metaTag.attributes.containsKey('content')
        ? metaTag.attributes['content'] ?? ''
        : '';
  }

  String _getParagraphs(Document document) {
    String body = '';
    List<Element> para = document.getElementsByTagName('p');
    para.forEach((element) {
      if (element.text != null &&
          element.text.isNotEmpty &&
          element.text.length > 150) {
        body += element.text.trim() + '\n\n';
      }
    });
    return body;
  }
}
