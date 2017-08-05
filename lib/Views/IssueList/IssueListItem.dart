import "dart:async";

import "package:flutter/material.dart";

import "../../Utilities.dart";
import "../../UIHelper.dart";
import "../../Data/Issue.dart";
import "../../Data/ContentManager.dart";

class IssueListItem extends StatefulWidget {
    IssueListItem({Key key, this.issue, this.downloadStatus, this.isDownloaded}) : super(key: key);

    final Issue issue;
    final DownloadStatus downloadStatus;
    final bool isDownloaded;

    @override
    _IssueListItemState createState() => new _IssueListItemState();
}

class _IssueListItemState extends State<IssueListItem> {

    void _onTap() {

        if (widget.isDownloaded) {
            _openIssue(widget.issue.id);
        }
    }

    Future<Null> _onLongPress() async {

        if (!widget.isDownloaded) {
            return;
        }

        var message = "Are you sure you want to delete this issue?\n\n${widget.issue.title}";
        var title = "Confirm Delete";

        var result = await UIHelper.confirm(message: message, title: title, context: context);

        if (result == Buttons.Yes) {

            // TODO: Show blocking modal activity spinner, dismiss on complete.
            var deleteResult = await on(ContentManager.instance.deleteIssue(widget.issue.id));

            if (deleteResult.error != null) {
                UIHelper.showSnackBar(message: "Error deleting issue", color: Colors.red, context: context);
                return;
            }

            UIHelper.showSnackBar(message: "Issue Deleted", context: context);
        }
    }

    void _onOpenIssueButtonPressed() {
        _openIssue(widget.issue.id);
    }

    void _onDownloadButtonPressed() {

        if (widget.downloadStatus != null && widget.downloadStatus.inProgress) {
            return;
        }

        ContentManager.instance.downloadIssue(widget.issue.id);
    }

    _openIssue(String issueID) {
        // TODO: Navigate to article list.
    }

    Widget _buildTrailingWidget() {

        var isThisIssueDownloading = widget.downloadStatus != null
                                        && widget.downloadStatus.inProgress
                                        && widget.downloadStatus.id == widget.issue.id;

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
                        value: status.percentage.roundToDouble() * 0.01,
                    ),
                );
            }
        }
        else if (widget.isDownloaded) {
            return new IconButton(
                icon: const Icon(Icons.keyboard_arrow_right),
                onPressed: _onOpenIssueButtonPressed,
            );
        }
        else {
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

            leading: new Image(
                image: new NetworkImage(widget.issue.imageURL)
            ),

            title: new Text(widget.issue.title),

            subtitle: new Text(widget.issue.summary),

            trailing: _buildTrailingWidget(),
        );
    }
}