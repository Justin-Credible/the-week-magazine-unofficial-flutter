import "dart:async";
import "dart:convert";

import "package:http/http.dart";
import "package:flutter/services.dart";
import "package:xml2json/xml2json.dart";

import "Issue.dart";

class TheWeekAPI {

    // TODO: Move to config file.
    // static String _url = "https://magazine.theweek.com/endpoint.xml";
    static const String _url = "https://home.justin-credible.net/private/the-week/endpoint.xml";
    static const String _baseURL = "https://home.justin-credible.net/private/the-week/";

    static Future<List<Issue>> retrieveIssueFeed() async {

        var completer = new Completer<List<Issue>>();

        var client = createHttpClient();

        client.get(TheWeekAPI._url)
            .then((Response response) {

            var xml2json = new Xml2Json();
            xml2json.parse(response.body);

            var json = xml2json.toGData();
            var wrapper = JSON.decode(json);
            var entries = wrapper["feed"]["entry"];

            var issues = new List<Issue>();

            entries.forEach((Map entry) {

                var issue = new Issue(
                    id: entry["id"]["\$t"],
                    title: entry["title"]["\$t"],
                    summary: entry["summary"]["\$t"],
                );

                entry["link"].forEach((Map link) {

                    if (link["rel"] == "http://opds-spec.org/image/thumbnail") {
                        issue.imageURL = _baseURL + link["href"];
                    }
                });

                issues.add(issue);
            });

            completer.complete(issues);

        }).catchError((Object error) {

            completer.completeError(error);
        });

        return completer.future;
    }
}
