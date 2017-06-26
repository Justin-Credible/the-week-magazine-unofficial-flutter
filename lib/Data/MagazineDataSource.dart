import "dart:async";

import "Cache.dart";
import "TheWeekAPI.dart";

class MagazineDataSource {

    static Future<Map> retrieveIssueFeed([CacheBehavior cacheBehavior = CacheBehavior.Default]) {

        var completer = new Completer<Map>();

        var entry = Cache.get<Map>("Issue_Feed", cacheBehavior);

        if (entry != null) {
            completer.complete(entry.item);
            return completer.future;
        }

        TheWeekAPI.retrieveIssueFeed()
            .then((Map feed) {

            var entry = new CacheEntry(feed, new Duration(days: 1));
            Cache.set("Issue_Feed", entry);

            completer.complete(feed);

        }).catchError((Object error) {

            completer.completeError(error);
        });

        return completer.future;
    }
}
