import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/remote_config_keys.dart';

SpellCheckResponse spellCheckResponseFromMap(String str) =>
    SpellCheckResponse.fromMap(json.decode(str));

String spellCheckResponseToMap(SpellCheckResponse data) =>
    json.encode(data.toMap());

class SpellCheckResponse {
  SpellCheckResponse({
    required this.text,
    required this.sentenceList,
  });

  String text;
  List<SentenceList> sentenceList;

  factory SpellCheckResponse.fromMap(Map<String, dynamic> json) =>
      SpellCheckResponse(
        text: json["text"],
        sentenceList: json["sentence_list"] == null
            ? []
            : List<SentenceList>.from(
                json["sentence_list"].map((x) => SentenceList.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "text": text,
        "sentence_list": List<dynamic>.from(sentenceList.map((x) => x.toMap())),
      };
}

class SentenceList {
  SentenceList({
    required this.offset,
    required this.text,
    required this.correctedText,
    required this.parseTree,
    required this.nbestParses,
  });

  int offset;
  String text;
  String correctedText;
  ParseTree parseTree;
  List<ParseTree> nbestParses;

  factory SentenceList.fromMap(Map<String, dynamic> json) => SentenceList(
        offset: json["offset"],
        text: json["text"],
        correctedText: json["corrected_text"],
        parseTree: ParseTree.fromMap(json["parse_tree"]),
        nbestParses: json["nbest_parses"] == null
            ? []
            : List<ParseTree>.from(
                json["nbest_parses"].map((x) => ParseTree.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "offset": offset,
        "text": text,
        "corrected_text": correctedText,
        "parse_tree": parseTree.toMap(),
        "nbest_parses": List<dynamic>.from(nbestParses.map((x) => x.toMap())),
      };
}

class ParseTree {
  ParseTree({
    this.id,
    this.phrases,
  });

  int? id;
  List<Phrase>? phrases;

  factory ParseTree.fromMap(Map<String, dynamic> json) => ParseTree(
        id: json["id"],
        phrases: json["phrases"] == null
            ? []
            : List<Phrase>.from(json["phrases"].map((x) => Phrase.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "phrases": phrases == null
            ? []
            : List<dynamic>.from(phrases!.map((x) => x.toMap())),
      };
}

class Phrase {
  Phrase({
    required this.type,
    required this.family,
    required this.offset,
    required this.length,
    required this.text,
    required this.children,
  });

  String type;
  int family;
  int offset;
  int length;
  String text;
  List<dynamic> children;

  factory Phrase.fromMap(Map<String, dynamic> json) => Phrase(
        type: json["type"],
        family: json["family"],
        offset: json["offset"],
        length: json["length"],
        text: json["text"],
        children: List<dynamic>.from(json["children"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "family": family,
        "offset": offset,
        "length": length,
        "text": text,
        "children": List<dynamic>.from(children.map((x) => x)),
      };
}

class SentimentExpression {
  SentimentExpression({
    required this.sentenceIndex,
    required this.offset,
    required this.length,
    required this.polarity,
  });

  int sentenceIndex;
  int offset;
  int length;
  String polarity;

  factory SentimentExpression.fromMap(Map<String, dynamic> json) =>
      SentimentExpression(
        sentenceIndex: json["sentence_index"],
        offset: json["offset"],
        length: json["length"],
        polarity: json["polarity"],
      );

  Map<String, dynamic> toMap() => {
        "sentence_index": sentenceIndex,
        "offset": offset,
        "length": length,
        "polarity": polarity,
      };
}

class SpellCheckManager {
  static String _getOcpApimKey() {
    final _random = new Random();
    List<String> listOfKeys;
    try {
      listOfKeys = List.from(
        json.decode(
          AppConfig.remoteConfig!.getString(RemoteConfigKeys.tisaneKeys),
        ),
      );
    } on Exception {
      listOfKeys = [
        "754b7ee07e8d49bb93542466f14d96b3",
        "dcfb68de198c49379634f779aa4b4ea0",
        "ca0982be53644221920ae9895c50bf83",
        "100e0be5b97b413d8238765aa6d8bff3",
        "1747bf96244a474b9ec919f4ec204135",
        "39ee6143bc824e0c82ad788f35a5ae4b"
      ];
    }
    var rand = 0 + _random.nextInt((listOfKeys.length - 1) - 0);
    return listOfKeys[rand];
  }

  static Future<SpellCheckResult> evaluateSpellingFor(
    String keyword, {
    String? language,
  }) async {
    String url = "https://api.tisane.ai/parse";
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Ocp-Apim-Subscription-Key": _getOcpApimKey()
    };
    dynamic body = jsonEncode({
      "language": language,
      "content": "$keyword",
      "settings": {'parses': true}
    });

    // log("Hitting api for $keyword");
    var spellChekRespons =
        await http.post(Uri.parse(url), headers: headers, body: body);

    switch (spellChekRespons.statusCode) {
      case HTTPResponseCodes.TOO_MANY_REQUESTS:
        return SpellCheckResult()
          ..hasErros = true
          ..errorType = SpellErrorType.RATE_LIMIT_EXCEEDED;

      case HTTPResponseCodes.RESULT_OK:
        return SpellCheckResult.evaluateKeywordResult(spellChekRespons.body);

      default:
        return SpellCheckResult()
          ..hasErros = true
          ..errorType = SpellErrorType.OTHER_ERROR;
    }
  }
}

class SpellCheckResult {
  bool? hasErros;
  bool? foundCorrectSpelling;
  String? correctSpelling;
  SpellErrorType? errorType;

  static SpellCheckResult evaluateKeywordResult(String responseBody) {
    var spellCheckRespone;
    try {
      spellCheckRespone = spellCheckResponseFromMap(responseBody);
    } catch (e) {
      logger.e(e);
      return SpellCheckResult()
        ..hasErros = true
        ..errorType = SpellErrorType.NO_SUGGESTIONS_FOUND;
    }

    if (spellCheckRespone != null &&
        spellCheckRespone.sentenceList != null &&
        spellCheckRespone.sentenceList.length > 0 &&
        spellCheckRespone.sentenceList[0].correctedText != null) {
      return SpellCheckResult()
        ..hasErros = false
        ..correctSpelling = spellCheckRespone.sentenceList[0].correctedText;
    } else {
      return SpellCheckResult()
        ..hasErros = true
        ..errorType = SpellErrorType.NO_SUGGESTIONS_FOUND;
    }
  }
}

enum SpellErrorType {
  RATE_LIMIT_EXCEEDED,
  NO_SUGGESTIONS_FOUND,
  OTHER_ERROR,
}

class HTTPResponseCodes {
  static const int TOO_MANY_REQUESTS = 429;
  static const int RESULT_OK = 200;
}
