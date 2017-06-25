import "dart:async";
import "package:flutter/material.dart";
import "../../MagazineDataSource.dart";
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
    List _entries = new List();

    Future<Null> refresh() {

        // Tell the refresh indicator to perform a refresh if one isn't already in progress.
        return _refreshIndicatorKey.currentState.show();
    }

    Future<Null> _doRefresh(bool forceRefresh) {

        var completer = new Completer();

        MagazineDataSource.retrieveIssueFeed(forceRefresh)
            .then((Map feed) {

            var entries = feed["entry"];

            setState(() { _entries = entries; });

            completer.complete(null);

        }).whenComplete(() {
            setState(() { _showSpinner = false; });
        });

        return completer.future;
    }

    @override
    initState() {
        super.initState();

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
            else if (_entries == null || _entries.length == 0) {

                return new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: new Column(
                        children: <Widget>[
                            const Text("No issues available."),
                            new RaisedButton(
                                child: new Text("Refresh"),
                                onPressed: () => refresh(),
                            ),
                        ],
                    ),
                );

            }
            else {

                return new ListView.builder(
                    padding: kMaterialListPadding,
                    itemCount: _entries.length,

                    itemBuilder: (BuildContext context, int index) {

                        Map entry = _entries[index];

                        return new Column(
                            children: [
                                new IssueListItem(issue: entry),
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