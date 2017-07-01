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


class ContentManager {
    static const channel = const MethodChannel("net.justin_credible.theweek.content_manager_plugin");

    static Future<Null> setContentBaseURL(String url) async {
        return await channel.invokeMethod("setContentBaseURL", url);
    }

    static Future<Map<String, bool>> getDownloadedIssues() async {
        return await channel.invokeMethod("getDownloadedIssues");
    }

    static Future<Null> downloadIssue(String issueID) async {
        return await channel.invokeMethod("downloadIssue", issueID);
    }

    static Future<Null> cancelDownload() async {
        return await channel.invokeMethod("cancelDownload");
    }

    static Future<DownloadStatus> getDownloadStatus() async {

        Map<String, Object> map = await channel.invokeMethod("getDownloadStatus");

        return new DownloadStatus(
            id: map["id"],
            inProgress: map["inProgress"],
            statusText: map["statusText"],
            percentage: map["percentage"],
        );
    }

    static Future<DownloadResult> getLastDownloadResult() async {

        Map<String, Object> map = await channel.invokeMethod("getLastDownloadResult");

        return new DownloadResult(
            message: map["message"],
            success: map["success"],
            cancelled: map["cancelled"],
        );
    }

    static Future<Null> deleteIssue(String issueID) async {
        return await channel.invokeMethod("deleteIssue", issueID);
    }

    static Future<String> getIssueContentXML(String issueID) async {
        return await channel.invokeMethod("getIssueContentXML", issueID);
    }

    static Future<String> getCoverImageFilePath(String issueID) async {
        return await channel.invokeMethod("getCoverImageFilePath", issueID);
    }

    static Future<int> getDownloadedIssuesSize() async {
        return await channel.invokeMethod("getDownloadedIssuesSize");
    }

    static Future<Null> deleteAllDownloadedIssues() async {
        return await channel.invokeMethod("deleteAllDownloadedIssues");
    }
}
