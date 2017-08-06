import "dart:async";
import "dart:convert";

import "package:xml2json/xml2json.dart";

import "../Utilities.dart";
import "ContentManager.dart";
import "Cache.dart";
import "TheWeekAPI.dart";
import "Issue.dart";
import "Article.dart";

class MagazineDataSource {

    static Future<List<Issue>> retrieveIssueFeed([CacheBehavior cacheBehavior = CacheBehavior.Default]) async {

        var completer = new Completer<List<Issue>>();

        var entry = Cache.get<List<Issue>>("Issue_Feed", cacheBehavior);

        if (entry != null) {
            completer.complete(entry.item);
            return completer.future;
        }

        TheWeekAPI.retrieveIssueFeed()
            .then((List<Issue> issues) {

            var entry = new CacheEntry(issues, new Duration(days: 1));
            Cache.set("Issue_Feed", entry);

            completer.complete(issues);

        }).catchError((Object error) {

            completer.completeError(error);
        });

        return completer.future;
    }

    static Future<List<Article>> retrieveArticles(String issueID) async {
        var completer = new Completer<List<Article>>();

        var result = await on(ContentManager.instance.getIssueContentXML(issueID));

        if (result.error != null) {
            completer.completeError(result.error);
            return completer.future;
        }

        var xml2json = new Xml2Json();
        xml2json.parse(result.data);

        var json = xml2json.toGData();
        var wrapper = JSON.decode(json);
        var entries = wrapper["feed"]["entry"];

        var articles = new List<Article>();

        entries.forEach((Map entry) {

            var article = new Article(
                id: entry["id"]["\$t"],
                title: entry["title"]["\$t"] ?? "",
                summary: entry["summary"]["\$t"] ?? "",
            );

            // TODO: Group by category?
            entry["link"].forEach((Map link) {

                if (link["rel"] == "alternate") {
                    article.localURI = link["href"];
                }
            });

            articles.add(article);
        });

        completer.complete(articles);

        return completer.future;
    }
}
