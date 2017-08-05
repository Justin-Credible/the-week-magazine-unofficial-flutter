import "dart:async";

import "Cache.dart";
import "TheWeekAPI.dart";
import "Issue.dart";

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
}
