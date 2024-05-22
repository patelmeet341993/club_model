import 'dart:convert';

import 'package:club_model/configs/credentials.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:http/http.dart' as http;

import '../../utils/my_print.dart';

class ElasticController {
  static final ElasticController _instance = ElasticController._();

  factory ElasticController() => _instance;

  late HttpTransport transport;
  late Client client;

  /*ElasticController.__(String url, String basicAuth) {
    transport = HttpTransport(url: url, authorization: basicAuth);
    client = Client(transport);
  }*/

  ElasticController._() {
    transport = HttpTransport(
      url: ElasticSearchCredentials.geBaseUrl(),
      authorization: ElasticSearchCredentials.getBasicAuth(),
    );
    client = Client(transport);
  }

  Future<bool> createDocument({required String index, required String docId, required Map<String, dynamic> data}) async {
    if (docId.isEmpty) return false;

    String url = ElasticSearchCredentials.geBaseUrl();
    url += "$index/_doc/$docId";

    Map<String, String> header = {
      "Authorization": ElasticSearchCredentials.getBasicAuth(),
      "Content-Type": "application/json",
    };

    Map<String, dynamic> body = data;

    MyPrint.printOnConsole("Url:$url");
    MyPrint.printOnConsole("Headers:$header");
    MyPrint.printOnConsole("Data:${jsonEncode(body)}");

    try {
      http.Response response = await http.put(Uri.parse(url), headers: header, body: jsonEncode(body));
      MyPrint.printOnConsole("Create Document Response For, Body: $docId:${response.body}, Status Code:${response.statusCode}");

      return response.statusCode == 201;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in ElasticController().createDocument():$e");
      MyPrint.printOnConsole(s);
    }

    return false;
  }

  Future<bool> updateDocument({required String index, required String docId, required Map<String, dynamic> data}) async {
    if (docId.isEmpty) return false;

    String url = ElasticSearchCredentials.geBaseUrl();
    url += "$index/_update/$docId";

    Map<String, String> header = {
      "Authorization": ElasticSearchCredentials.getBasicAuth(),
      "Content-Type": "application/json",
    };

    Map<String, dynamic> body = {
      "doc": data,
    };

    try {
      http.Response response = await http.post(Uri.parse(url), headers: header, body: jsonEncode(body));
      MyPrint.printOnConsole("Update Document Response For $docId:${response.body}");

      return response.statusCode == 200;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in ElasticController().updateDocument():$e");
      MyPrint.printOnConsole(s);
    }

    return false;
  }

  Future<bool> deleteDocument({required String index, required String docId}) async {
    if (docId.isEmpty) return false;

    String url = ElasticSearchCredentials.geBaseUrl();
    url += "$index/_doc/$docId";

    Map<String, String> header = {
      "Authorization": ElasticSearchCredentials.getBasicAuth(),
      "Content-Type": "application/json",
    };

    try {
      http.Response response = await http.delete(Uri.parse(url), headers: header);
      MyPrint.printOnConsole("Delete Document Response For, Body: $docId:${response.body}, Status Code:${response.statusCode}");

      return response.statusCode == 201;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in ElasticController().deleteDocument():$e");
      MyPrint.printOnConsole(s);
    }

    return false;
  }

  Future<Doc?> getDocument({required String index, required String docId}) async {
    if (docId.isEmpty) return null;
    MyPrint.printOnConsole('GetDocument Called');

    String url = ElasticSearchCredentials.geBaseUrl();
    url += "$index/_doc/$docId";

    Map<String, String> header = {
      "Authorization": ElasticSearchCredentials.getBasicAuth(),
      "Content-Type": "application/json",
    };

    MyPrint.printOnConsole("Url:$url");
    MyPrint.printOnConsole("Header:$header");

    //MyPrint.printOnConsole("Get Document Status For $docId:${response.statusCode}");
    //MyPrint.printOnConsole("Get Document Response For $docId:${response.body}");

    Doc? doc;

    try {
      http.Response response = await http.get(Uri.parse(url), headers: header);
      MyPrint.printOnConsole("Get Document Response For, Body: $docId:${response.body}, Status Code:${response.statusCode}");

      if (response.statusCode == 200) {
        Map<String, dynamic> data = Map.castFrom(jsonDecode(response.body));
        doc = Doc(data['_id'], Map.castFrom(data['_source'] ?? {}));
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in ElasticController().getDocument():$e");
      MyPrint.printOnConsole(s);
    }

    return doc;
  }

  /*Future<void> _copyDocsFromOneToOtherElastic() async {
    ElasticController elasticControllerOld = ElasticController.__(
      ElasticSearchCredentials.geBaseUrl(),
      ElasticSearchCredentials.getBasicAuth(),
    );
    ElasticController elasticControllerNew = ElasticController.__(
      "https://sportiwe-dev-770218.es.asia-south1.gcp.elastic-cloud.com:9243/",
      "Basic ZWxhc3RpYzozaVdWQ1prY3NoQVJod0NpZGxNSVRPNmY=",
    );

    SearchResult searchResult = await elasticControllerOld.client.search(index: getVenuesIndex(), limit: 10000);
    MyPrint.printOnConsole("Hits:${searchResult.hits.length}");

    List<Doc> docs = searchResult.hits.map((e) {
      return Doc(e.id, e.doc);
    }).toList();

    await elasticControllerNew.client.bulk(index: getVenuesIndex(), updateDocs: docs);
  }*/

  Future<bool> arrayUnion({required String index, required String docId, required String key, required List<dynamic> data}) async {
    if (docId.isEmpty) return false;

    String url = ElasticSearchCredentials.geBaseUrl();
    url += "$index/_update/$docId";

    Map<String, String> header = {
      "Authorization": ElasticSearchCredentials.getBasicAuth(),
      "Content-Type": "application/json",
    };
    // ReporterModel reporterModel  = ReporterModel(
    //     status: "Pending",
    //     created_time: Timestamp.now(),
    //     description: "This",
    //     reportersId: "xyz"
    // );

    Map<String, dynamic> body = {
      "script": {
        "source": "ctx._source.$key.addAll(params.reporter)",
        "lang": "painless",
        "params": {
          "reporter": data,
        }
      }
    };

    http.Response? response;
    try {
      response = await http.post(Uri.parse(url), headers: header, body: jsonEncode(body));
      MyPrint.printOnConsole("arrayUnion Document Response For $docId:${response.body}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error in arrayUnion from ElasticController:$e");
      MyPrint.printOnConsole(s);
    }

    return response?.statusCode == 200;
  }

  Future<bool> arrayRemove({required String index, required String docId, required String key, required List<dynamic> data}) async {
    if (docId.isEmpty) return false;

    String url = ElasticSearchCredentials.geBaseUrl();
    url += "$index/_update/$docId";

    Map<String, String> header = {
      "Authorization": ElasticSearchCredentials.getBasicAuth(),
      "Content-Type": "application/json",
    };
    // ReporterModel reporterModel  = ReporterModel(
    //     status: "Pending",
    //     created_time: Timestamp.now(),
    //     description: "This",
    //     reportersId: "xyz"
    // );

    Map<String, dynamic> body = {
      "script": {
        "source": "ctx._source.$key.removeAll(params.reporter)",
        "lang": "painless",
        "params": {
          "reporter": data,
        }
      }
    };

    http.Response? response;
    try {
      response = await http.post(Uri.parse(url), headers: header, body: jsonEncode(body));
      MyPrint.printOnConsole("arrayRemove Document Response For $docId:${response.body}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error in arrayRemove from ElasticController:$e");
      MyPrint.printOnConsole(s);
    }

    return response?.statusCode == 200;
  }
}
