import "dart:async";

/// A result class to wrap async/await function calls.
/// For use with the on() function.
class AsyncResult<T> {

    AsyncResult({this.data, this.error});

    T data;
    Object error;
}

/// A helper function for use with the await keyword that allows
/// retrieving the result and error in a single object so the
/// caller can avoid using try/catch around all their calls.
/// 
/// var result = await on(someAsyncFunction());
/// if (result.error != null) { // handle error }
/// else { // continue as normal }
Future<AsyncResult<T>> on<T>(Future<T> futureToWaitOn) async {

    var completer = new Completer<AsyncResult<T>>();

    futureToWaitOn.then((T data) {
        completer.complete(new AsyncResult<T>(data: data));
    }).catchError((Object error) {
        completer.complete(new AsyncResult<T>(error: error));
    });

    return completer.future;
}
