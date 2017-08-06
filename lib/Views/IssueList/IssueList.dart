import "dart:async";

import "package:flutter/material.dart";

import "../../Utilities.dart";
import "../../UIHelper.dart";
import "../../Data/Cache.dart";
import "../../Data/Issue.dart";
import "../../Data/MagazineDataSource.dart";
import "../../Data/ContentManager.dart";
import "IssueListItem.dart";

class IssueList extends StatefulWidget {
    IssueList({Key key, this.title}) : super(key: key);

    final String title;

    @override
    IssueListState createState() => new IssueListState();
}

class IssueListState extends State<IssueList> {

    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

    bool _showSpinner = false;
    DownloadStatus _downloadStatus;
    List<Issue> _issues = new List<Issue>();
    Map<String, bool> _downloadedIssuesMap = new Map<String, bool>();

    Future<Null> refresh() {

        // Tell the refresh indicator to perform a refresh if one isn't already in progress.
        return _refreshIndicatorKey.currentState.show();
    }

    Future<Null> _doRefresh(bool forceRefresh) async {

        if (_downloadStatus != null && _downloadStatus.inProgress) {
            return;
        }

        var cacheBehavior = forceRefresh ? CacheBehavior.InvalidateCache : CacheBehavior.AllowStale;

        var issueFeedResult = await on(MagazineDataSource.retrieveIssueFeed(cacheBehavior));

        setState(() { _showSpinner = false; });

        if (issueFeedResult.error != null) {
            UIHelper.showSnackBar(message: "Error refreshing list.", color: Colors.red, context: context);
            return;
        }

        setState(() { _issues = issueFeedResult.data; });

        var downloadedIssuesResult = await on(ContentManager.instance.getDownloadedIssues());

        if (downloadedIssuesResult.error != null) {
            UIHelper.showSnackBar(message: "Error getting list of downloaded issues.", color: Colors.red, context: context);
            return;
        }

        Map downloadedIssues = downloadedIssuesResult.data;

        setState(() { _downloadedIssuesMap = downloadedIssues; });
    }

    _onDownloadStatusChanged(DownloadStatus status) {

        setState(() {
            print("DownloadStatusChanged: ${status.id} / ${status.inProgress} / ${status.percentage} / ${status.statusText}");
            _downloadStatus = status;
        });

        if (status.statusText == "Complete") {
            // Tell the refresh indicator to perform a refresh if one isn't already in progress.
            _refreshIndicatorKey.currentState.show();
        }
    }

    _onIssueDeleted() {

        // Tell the refresh indicator to perform a refresh if one isn't already in progress.
        _refreshIndicatorKey.currentState.show();
    }

    @override
    initState() {
        super.initState();

        ContentManager.instance.addDownloadStatusChangedListener("IssueList", _onDownloadStatusChanged);
        ContentManager.instance.addIssueDeletedListener("IssueList", _onIssueDeleted);

        _showSpinner = true;
        _doRefresh(false);
    }

    @override
    Widget build(BuildContext context) {

        Widget buildChild() {

            if (_showSpinner) {

                return new Center(
                    child: new CircularProgressIndicator()
                );
            }
            else if (_issues == null || _issues.length == 0) {

                return new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: new Center(
                        child: new Column(
                            children: <Widget>[
                                const Text("No issues available."),
                                new RaisedButton(
                                    child: new Text("Refresh"),
                                    onPressed: () => refresh(),
                                ),
                            ],
                        ),
                    ),
                );

            }
            else {

                return new ListView.builder(
                    padding: kMaterialListPadding,
                    itemCount: _issues.length,

                    itemBuilder: (BuildContext context, int index) {

                        Issue issue = _issues[index];

                        bool isDownloaded = _downloadedIssuesMap[issue.id] ?? false;

                        return new Column(
                            children: [
                                new IssueListItem(issue: issue, downloadStatus: _downloadStatus, isDownloaded: isDownloaded),
                                new Divider(),
                            ]
                        );
                    },
                );
            }
        }

        return new RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () => _doRefresh(true),
            child: buildChild(),
        );
    }
}
