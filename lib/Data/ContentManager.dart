import "dart:async";

import "package:flutter/services.dart";

class DownloadStatus {

    bool inProgress;
    String id;
    String statusText;
    int percentage;

    DownloadStatus({this.inProgress, this.id, this.statusText, this.percentage});
}

class DownloadResult {

    String message;
    bool success;
    bool cancelled;

    DownloadResult({this.message, this.success, this.cancelled});
}

typedef void DownloadStatusChangedHandler(DownloadStatus status);
typedef void IssueDeletedHandler();

class ContentManager {

    // TODO: Move to config file.
    static const String _url = "https://home.justin-credible.net/private/the-week/";

    static ContentManager instance;

    factory ContentManager() {

        if (instance == null) {
            instance = new ContentManager._internal();
        }

        return instance;
    }

    ContentManager._internal() {
        _channel = new MethodChannel("net.justin_credible.theweek.content_manager_plugin");
        _channel.setMethodCallHandler(_handler);
        setContentBaseURL(_url);
    }

    MethodChannel _channel;
    Map<String, DownloadStatusChangedHandler> _downloadStatusChangedHandlers = new Map();
    Map<String, IssueDeletedHandler> _issueDeletedHandlers = new Map();

    Future<dynamic> _handler(MethodCall call) async {

        switch (call.method) {
            case "downloadStatusChanged":
                {
                    var status = new DownloadStatus(
                        id: call.arguments["id"],
                        inProgress: call.arguments["inProgress"],
                        statusText: call.arguments["statusText"],
                        percentage: call.arguments["percentage"],
                    );

                    _fireDownloadStatusChangedListeners(status);

                    break;
                }
            default:
                break;
        }
    }

    addDownloadStatusChangedListener(String listenerID, DownloadStatusChangedHandler handler) {
        _downloadStatusChangedHandlers[listenerID] = handler;
    }

    removeDownloadStatusChangedListener(String listenerID) {
        _downloadStatusChangedHandlers.remove(listenerID);
    }

    _fireDownloadStatusChangedListeners(DownloadStatus status) {

        _downloadStatusChangedHandlers.forEach((String listenerID, DownloadStatusChangedHandler handler) {
            handler(status);
        });
    }

    addIssueDeletedListener(String listenerID, IssueDeletedHandler handler) {
        _issueDeletedHandlers[listenerID] = handler;
    }

    removeIssueDeletedListener(String listenerID) {
        _issueDeletedHandlers.remove(listenerID);
    }

    _fireIssueDeletedListeners() {

        _issueDeletedHandlers.forEach((String listenerID, IssueDeletedHandler handler) {
            handler();
        });
    }

    Future<Null> setContentBaseURL(String url) async {
        return await _channel.invokeMethod("setContentBaseURL", {
            "url": url,
        });
    }

    Future<Map<String, bool>> getDownloadedIssues() async {
        return await _channel.invokeMethod("getDownloadedIssues");
    }

    Future<Null> downloadIssue(String issueID) async {
        return await _channel.invokeMethod("downloadIssue", {
            "id": issueID
        });
    }

    Future<Null> cancelDownload() async {
        return await _channel.invokeMethod("cancelDownload");
    }

    Future<DownloadStatus> getDownloadStatus() async {

        Map<String, Object> map = await _channel.invokeMethod("getDownloadStatus");

        return new DownloadStatus(
            id: map["id"],
            inProgress: map["inProgress"],
            statusText: map["statusText"],
            percentage: map["percentage"],
        );
    }

    Future<DownloadResult> getLastDownloadResult() async {

        Map<String, Object> map = await _channel.invokeMethod("getLastDownloadResult");

        return new DownloadResult(
            message: map["message"],
            success: map["success"],
            cancelled: map["cancelled"],
        );
    }

    Future<Null> deleteIssue(String issueID) async {

        var result = await _channel.invokeMethod("deleteIssue", {
            "id": issueID,
        });

        _fireIssueDeletedListeners();

        return result;
    }

    Future<String> getIssueContentXML(String issueID) async {
        return await _channel.invokeMethod("getIssueContentXML", {
            "id": issueID,
        });
    }

    Future<String> getCoverImageFilePath(String issueID) async {
        return await _channel.invokeMethod("getCoverImageFilePath", {
            "id": issueID,
        });
    }

    Future<int> getDownloadedIssuesSize() async {
        return await _channel.invokeMethod("getDownloadedIssuesSize");
    }

    Future<Null> deleteAllDownloadedIssues() async {

        var result = await _channel.invokeMethod("deleteAllDownloadedIssues");

        _fireIssueDeletedListeners();

        return result;
    }
}
