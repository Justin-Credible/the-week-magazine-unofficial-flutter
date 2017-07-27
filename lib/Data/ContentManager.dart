import "dart:async";

import "package:flutter/services.dart";
import "../Eventable/eventable.dart";

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


class ContentManager extends Object with EventEmitter {

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

    Future<dynamic> _handler(MethodCall call) async {

        switch (call.method) {
            case "downloadStatusChanged":
                {
                    // TODO: Use debugger to determine how results are returned.
                    // var status = new DownloadStatus(
                    //     id: map["id"],
                    //     inProgress: map["inProgress"],
                    //     statusText: map["statusText"],
                    //     percentage: map["percentage"],
                    // );

                    emitEvent(new DownloadStatus());

                    break;
                }
            default:
                break;
        }
    }

    Future<Null> setContentBaseURL(String url) async {
        return await _channel.invokeMethod("setContentBaseURL", url);
    }

    Future<Map<String, bool>> getDownloadedIssues() async {
        return await _channel.invokeMethod("getDownloadedIssues");
    }

    Future<Null> downloadIssue(String issueID) async {
        return await _channel.invokeMethod("downloadIssue", issueID);
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
        return await _channel.invokeMethod("deleteIssue", issueID);
    }

    Future<String> getIssueContentXML(String issueID) async {
        return await _channel.invokeMethod("getIssueContentXML", issueID);
    }

    Future<String> getCoverImageFilePath(String issueID) async {
        return await _channel.invokeMethod("getCoverImageFilePath", issueID);
    }

    Future<int> getDownloadedIssuesSize() async {
        return await _channel.invokeMethod("getDownloadedIssuesSize");
    }

    Future<Null> deleteAllDownloadedIssues() async {
        return await _channel.invokeMethod("deleteAllDownloadedIssues");
    }
}
