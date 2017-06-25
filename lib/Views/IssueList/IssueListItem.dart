import "package:flutter/material.dart";

class IssueListItem extends StatefulWidget {
    IssueListItem({Key key, this.issue}) : super(key: key);

    final Map issue;

    @override
    _IssueListItemState createState() => new _IssueListItemState();
}

class _IssueListItemState extends State<IssueListItem> {

    bool _isDownloading = false;
    double _downloadPercentage = 0.0;

    void _onTap() {
        // TODO: Open issue.
    }

    void _onLongPress() {
        // TODO: Show issue file size info, offer to delete.
    }

    Widget _buildTrailingWidget() {

        if (_isDownloading && _downloadPercentage <= 5) {

            return new SizedBox(
                width: 20.0,
                height: 20.0,
                child: new CircularProgressIndicator(),
            );
        }
        else if (_isDownloading) {

            return new SizedBox(
                width: 20.0,
                height: 20.0,
                child: new CircularProgressIndicator(
                    value: _downloadPercentage,
                ),
            );
        }
        else { // TODO: If already downloaded, show a checkmark icon.
            return const Icon(Icons.file_download);
        }
    }

    @override
    Widget build(BuildContext context) {

        return new ListTile(

            onTap: _onTap,
            onLongPress: _onLongPress,

            isThreeLine: true,

            leading: new FlutterLogo(),

            title: new Text(widget.issue["title"]),

            subtitle: new Text(widget.issue["summary"]),

            trailing: _buildTrailingWidget(),
        );
    }
}