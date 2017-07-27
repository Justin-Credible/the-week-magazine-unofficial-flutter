package net.justin_credible.theweek;

import android.app.Activity;
import android.content.Context;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;

import java.io.File;
import java.text.MessageFormat;
import java.util.HashMap;
import java.util.Map;

public final class ContentManagerPlugin {

    private Activity activity;
    private MethodChannel channel;
    private String baseContentURL;
    private DownloadTask currentDownloadTask;
    private DownloadStatus currentDownloadStatus = new DownloadStatus();
    private DownloadResult lastDownloadResult;

    ContentManagerPlugin(Activity activity, MethodChannel channel) {
        this.activity = activity;
        this.channel = channel;

        channel.setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
                @Override
                public void onMethodCall(MethodCall call, Result result) {

                    boolean handled = execute(call, result);

                    if (!handled) {
                        result.notImplemented();
                    }
                }
            });
    }

    //region Plugin Entry Point

    public synchronized boolean execute(MethodCall call, Result result) {

        String action = call.method;

        if (action == null) {
            return false;
        }

        if (action.equals("setContentBaseURL")) {

            try {
                this.setContentBaseURL(call, result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.setContentBaseURL() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("getDownloadedIssues")) {

            try {
                this.getDownloadedIssues(result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.getDownloadedIssues() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("downloadIssue")) {

            try {
                this.downloadIssue(call, result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.downloadIssue() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("cancelDownload")) {

            try {
                this.cancelDownload(result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.cancelDownload() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("getDownloadStatus")) {

            try {
                this.getDownloadStatus(result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.getDownloadStatus() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("getLastDownloadResult")) {

            try {
                this.getLastDownloadResult(result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.getLastDownloadResult() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("deleteIssue")) {

            try {
                this.deleteIssue(call, result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.deleteIssue() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("getIssueContentXML")) {

            try {
                this.getIssueContentXML(call, result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.getIssueContentXML() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("getCoverImageFilePath")) {

            try {
                this.getCoverImageFilePath(call, result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.getCoverImageFilePath() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("getDownloadedIssuesSize")) {

            try {
                this.getDownloadedIssuesSize(result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.getDownloadedIssuesSize() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else if (action.equals("deleteAllDownloadedIssues")) {

            try {
                this.deleteAllDownloadedIssues(result);
            }
            catch (Exception exception) {
                result.error("UNCAUGHT_EXCEPTION", "ContentManagerPlugin.deleteAllDownloadedIssues() uncaught exception: " + exception.getMessage(), exception.getMessage());
            }

            return true;
        }
        else {
            // The given action was not handled above.
            return false;
        }
    }

    //endregion

    //region Plugin Methods

    private synchronized void setContentBaseURL(final MethodCall call, final Result result) {

        // TODO: Update all statements to get arguments; call.argument is a string at this point.
        String baseContentURL = call.argument("url");

        if (baseContentURL == null || baseContentURL.equals("")) {
            result.error("INVALID_ARGUMENT", "A URL is required.", null);
            return;
        }

        this.baseContentURL = baseContentURL;

        result.success(null);
    }

    private synchronized void getDownloadedIssues(final Result result) {

        Map<String, Boolean> map = new HashMap<>();

        Context appContext = this.activity.getApplicationContext();
        String baseStorageDir = appContext.getFilesDir().toString();

        String issuesDirPath = Utilities.combinePaths(baseStorageDir, "issues");

        File issuesDir = new File(issuesDirPath);

        if (!issuesDir.exists() || !issuesDir.isDirectory()) {
            result.success(map);
            return;
        }

        for (File childFile : issuesDir.listFiles()) {

            if (!childFile.isDirectory()) {
                continue;
            }

            String completeTagPath = Utilities.combinePaths(childFile.getAbsolutePath(), "complete.id");

            File completeTagFile = new File(completeTagPath);

            map.put(childFile.getName(), completeTagFile.exists());
        }

        result.success(map);
    }

    private synchronized void downloadIssue(final MethodCall call, final Result result) {

        if (baseContentURL == null) {
            result.error("INVALID_ARGUMENT", "A content base URL must be set using setContentBaseURL before invoking this method.", null);
            return;
        }

        if (currentDownloadTask != null) {
            result.error("INVALID_ARGUMENT", "Another download is already in progress.", null);
            return;
        }

        String id = call.argument("id");

        // Create an initial status so there is something to return if the client queries for
        // the status before the download task has gotten to do any work.
        currentDownloadStatus = new DownloadStatus();
        currentDownloadStatus.inProgress = true;
        currentDownloadStatus.id = id;
        currentDownloadStatus.statusText = "Starting";
        currentDownloadStatus.percentage = 0;

        currentDownloadTask = new DownloadTask() {

            @Override
            protected void onProgressUpdate(DownloadStatus... status) {
                currentDownloadStatus = status[0];
                channel.invokeMethod("downloadStatusChanged", status[0]);
            }

            @Override
            protected void onPostExecute(DownloadResult result) {
                currentDownloadTask = null;
                currentDownloadStatus = new DownloadStatus();
                lastDownloadResult = result;
            }

            @Override
            protected void onCancelled() {
                currentDownloadTask = null;
                currentDownloadStatus = new DownloadStatus();
                lastDownloadResult = new DownloadResult("Download was cancelled.");
                lastDownloadResult.cancelled = true;
                channel.invokeMethod("downloadStatusChanged", currentDownloadStatus);
            }
        };

        Context appContext = this.activity.getApplicationContext();

        currentDownloadTask.setBaseStorageDir(appContext.getFilesDir().toString());
        currentDownloadTask.setBaseContentURL(baseContentURL);

        try {
            currentDownloadTask.execute(id);
        }
        catch (Exception exception) {

            currentDownloadTask = null;
            currentDownloadStatus = new DownloadStatus();

            result.error("CANT_START_DOWNLOAD", "An error occurred while starting the download: ", exception.getMessage());

            return;
        }

        result.success(null);
    }

    private synchronized void cancelDownload(final Result result) {

        if (currentDownloadTask == null) {
            result.error("DOWNLOAD_IN_PROGRESS", "A download is not currently in progress.", null);
            return;
        }

        currentDownloadTask.cancel(true);

        result.success(null);
    }

    private synchronized void getDownloadStatus(final Result result) {

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("inProgress", currentDownloadStatus.inProgress);
        resultMap.put("id", currentDownloadStatus.id);
        resultMap.put("statusText", currentDownloadStatus.statusText);
        resultMap.put("percentage", currentDownloadStatus.percentage);

        result.success(resultMap);
    }

    private synchronized void getLastDownloadResult(final Result result) {

        if (lastDownloadResult == null) {
            result.success(null);
        }

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("message", lastDownloadResult.message);
        resultMap.put("success", lastDownloadResult.success);
        resultMap.put("cancelled", lastDownloadResult.cancelled);

        result.success(resultMap);
    }

    private synchronized void deleteIssue(final MethodCall call, final Result result) throws Exception {

        String id = call.argument("id");

        if (id == null || id.equals("")) {
            result.error("INVALID_ARGUMENT", "An issue ID is required to delete an issue.", null);
            return;
        }

        Context appContext = this.activity.getApplicationContext();
        String baseStorageDir = appContext.getFilesDir().toString();

        String issueDirPath = Utilities.combinePaths(baseStorageDir, "issues");
        issueDirPath = Utilities.combinePaths(issueDirPath, id);

        File issueDir = new File(issueDirPath);

        if (!issueDir.exists() || !issueDir.isDirectory()) {
            result.error("ISSUE_NOT_FOUND", MessageFormat.format("An issue directory for ID '{0}' was not found.", id), id);
            return;
        }

        Utilities.deleteDir(issueDir);

        result.success(null);
    }

    private synchronized void getIssueContentXML(final MethodCall call, final Result result) throws Exception {

        String id = call.argument("id");

        if (id == null || id.equals("")) {
            result.error("INVALID_ARGUMENT", "An issue ID is required to retrieve content XML for an issue.", null);
            return;
        }

        Context appContext = this.activity.getApplicationContext();
        String baseStorageDir = appContext.getFilesDir().toString();

        String issueDirPath = Utilities.combinePaths(baseStorageDir, "issues");
        issueDirPath = Utilities.combinePaths(issueDirPath, id);

        File issueDir = new File(issueDirPath);

        if (!issueDir.exists() || !issueDir.isDirectory()) {
            result.error("ISSUE_NOT_FOUND", MessageFormat.format("An issue with ID '{0}' was not found.", id), id);
            return;
        }

        String contentXMLPath = Utilities.combinePaths(issueDirPath, "content.xml");
        File contentXMLFile = new File(contentXMLPath);

        if (!contentXMLFile.exists()) {
            result.error("CONTENT_XML_NOT_FOUND", MessageFormat.format("An content.xml manifest for issue with ID '{0}' was not found.", id), id);
            return;
        }

        String contentXML = Utilities.readFile(contentXMLPath);

        result.success(contentXML);
    }

    private synchronized void getCoverImageFilePath(final MethodCall call, final Result result) throws Exception {

        final String issueID = call.argument("id");

        if (issueID == null || issueID.equals("")) {
            result.error("INVALID_ARGUMENT", "An issue ID is required to retrieve a cover image file path for an issue.", null);
            return;
        }

        Context appContext = this.activity.getApplicationContext();
        String baseStorageDir = appContext.getFilesDir().toString();

        String issuesDirPath = Utilities.combinePaths(baseStorageDir, "issues");
        final String issueDirPath = Utilities.combinePaths(issuesDirPath, issueID);

        File issueDir = new File(issueDirPath);

        if (!issueDir.exists() || !issueDir.isDirectory()) {
            result.error("ISSUE_NOT_FOUND", MessageFormat.format("An issue with ID '{0}' was not found.", issueID), issueID);
            return;
        }

        final String contentXMLPath = Utilities.combinePaths(issueDirPath, "content.xml");
        File contentXMLFile = new File(contentXMLPath);

        if (!contentXMLFile.exists()) {
            result.error("CONTENT_XML_NOT_FOUND", MessageFormat.format("An content.xml manifest for issue with ID '{0}' was not found.", issueID), issueID);
            return;
        }

        // TODO: Use a background thread?
        // cordova.getThreadPool().execute(new Runnable() {
        //     public void run() {
                try {
                    String contentXML = Utilities.readFile(contentXMLPath);

                    String coverPageID = Utilities.getCoverPageID(contentXML);

                    String pagePath = MessageFormat.format("editions/{0}/data/{1}", issueID, coverPageID);
                    String searchPath = Utilities.combinePaths(issueDirPath, pagePath);

                    String imagePath = Utilities.findFileWithExtension(searchPath, "jpg");

                    result.success(imagePath);
                }
                catch (Exception exception) {
                    result.error("CANT_GET_PATH", "ContentManagerPlugin.getCoverImageFilePath() exception during image path acquisition.", exception.getMessage());
                }
        //     }
        // });
    }

    private synchronized void getDownloadedIssuesSize(final Result result) throws Exception {

        Context appContext = this.activity.getApplicationContext();
        String baseStorageDir = appContext.getFilesDir().toString();

        String issuesDirPath = Utilities.combinePaths(baseStorageDir, "issues");
        File issuesDir = new File(issuesDirPath);

        if (!issuesDir.exists() || !issuesDir.isDirectory()) {
            result.success(0);
            return;
        }

        long totalSize = Utilities.getFileSize(issuesDir);

        result.success((int)totalSize);
    }


    private synchronized void deleteAllDownloadedIssues(final Result result) throws Exception {

        if (currentDownloadStatus != null && currentDownloadStatus.inProgress) {
            result.error("DOWNLOAD_IN_PROGRESS", "Cannot delete all issues because a download is currently in progress.", null);
            return;
        }

        Context appContext = this.activity.getApplicationContext();
        String baseStorageDir = appContext.getFilesDir().toString();

        String issuesDirPath = Utilities.combinePaths(baseStorageDir, "issues");
        final File issuesDir = new File(issuesDirPath);

        if (!issuesDir.exists()) {
            result.success(null);
            return;
        }

        // TODO: Use a background thread?
        // cordova.getThreadPool().execute(new Runnable() {
        //     public void run() {
                try {
                    Utilities.deleteDir(issuesDir);
                    result.success(null);
                }
                catch (Exception exception) {
                    result.error("DELETE_FAILURE", "ContentManagerPlugin.deleteAllDownloadedIssues() exception during deletion.", exception.getMessage());
                }
        //     }
        // });
    }

    //endregion
}
