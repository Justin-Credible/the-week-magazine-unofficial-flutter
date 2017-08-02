import "package:flutter/material.dart";

import "../../Data/ContentManager.dart";

class IssueListItem extends StatefulWidget {
    IssueListItem({Key key, this.issue, this.downloadStatus}) : super(key: key);

    final Map issue;
    final DownloadStatus downloadStatus;

    @override
    _IssueListItemState createState() => new _IssueListItemState();
}

class _IssueListItemState extends State<IssueListItem> {

    void _onTap() {
        // TODO: Open issue.
    }

    void _onLongPress() {
        // TODO: Show issue file size info, offer to delete.
    }

    void _onDownloadButtonPressed() {

        if (widget.downloadStatus != null && widget.downloadStatus.inProgress) {
            return;
        }

        ContentManager.instance.downloadIssue(widget.issue["id"]);
    }

    Widget _buildTrailingWidget() {

        var isThisIssueDownloading = widget.downloadStatus != null
                                        && widget.downloadStatus.inProgress
                                        && widget.downloadStatus.id == widget.issue["id"];

        if (isThisIssueDownloading) {

            var status = widget.downloadStatus;

            if (status.percentage <= 5) {

                return new SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: new CircularProgressIndicator(),
                );
            }
            else {
                return new SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: new CircularProgressIndicator(
                        value: status.percentage.roundToDouble(),
                    ),
                );
            }
        }
        else { // TODO: If already downloaded, show a checkmark icon.
            //return const Icon(Icons.file_download);
            return new IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: _onDownloadButtonPressed,
            );
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