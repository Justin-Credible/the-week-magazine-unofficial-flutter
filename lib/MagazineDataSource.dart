import "dart:async";
import "TheWeekAPI.dart";

class MagazineDataSource {

    static Future<Map> retrieveIssueFeed({bool forceRefresh}) {

        var completer = new Completer<Map>();

        // TODO: Caching logic.
        TheWeekAPI.retrieveIssueFeed()
            .then((Map feed) {

            completer.complete(feed);

        }).catchError((Object error) {

            completer.completeError(error);
        });

        return completer.future;
    }
}
