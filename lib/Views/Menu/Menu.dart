import "dart:core";
import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter/material.dart";

import "../../UIHelper.dart";
import "../../Data/ContentManager.dart";

class Menu extends StatefulWidget {
    Menu({Key key}) : super(key: key);

    @override
    _MenuState createState() => new _MenuState();
}

class _MenuState extends State<Menu> {

    int _totalIssueSizeOnDisk = -1;

    void _issuesOnTap() {
        // TODO
    }

    Future<Null> _storageOnTap(BuildContext context) async {

        var message = "Are you sure you want to delete all of the downloaded issues?";
        var title = "Delete All Issues";
        var result = await UIHelper.confirm(message: message, title: title, context: context);

        if (result == "Yes") {

            // TODO: Show model activity spinner, dismiss on complete.

            await ContentManager.instance.deleteAllDownloadedIssues();

            // TODO: Show toast message indicating result
            // TODO: Fire event so root can refresh the list.

            _calculateTotalSpaceUsedDisplay();
        }
    }

    void _downloadSwitchChanged(bool value) {
        // TODO
    }

    void _aboutOnTap() {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/about");
    }

    void _calculateTotalSpaceUsedDisplay() {

        ContentManager.instance.getDownloadedIssuesSize().then((int totalIssueSizeOnDisk) {

            setState(() {
                _totalIssueSizeOnDisk = (totalIssueSizeOnDisk / 1024 / 1024).ceil();
            });
        });
    }

    @override
    initState() {
        super.initState();

        _calculateTotalSpaceUsedDisplay();
    }

    @override
    Widget build(BuildContext context) {

        final ThemeData themeData = Theme.of(context);
        final TextStyle headerStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);

        return new Container(
            color: Colors.white,
            width: 280.0,
            child: new ListView(

                children: [
                    new FlutterLogo(), // TODO

                    new Container(
                        height: 48.0,
                        padding: const EdgeInsets.only(left: 16.0),
                        alignment: FractionalOffset.centerLeft,
                        child: new Text("The Week (Unofficial)", style: headerStyle)
                    ),

                    new ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text("Issues"),
                        onTap: _issuesOnTap,
                    ),

                    new Container(
                        height: 48.0,
                        padding: const EdgeInsets.only(left: 16.0),
                        alignment: FractionalOffset.centerLeft,
                        child: new Text("Preferences", style: headerStyle)
                    ),

                    new ListTile(
                        leading: const Icon(Icons.storage),
                        title: const Text("Storage Used"),
                        trailing: _totalIssueSizeOnDisk == -1 ? new CircularProgressIndicator() : new Text("${_totalIssueSizeOnDisk} MB"),
                        subtitle: _totalIssueSizeOnDisk == -1 ? const Text("Calculating...") : const Text("Tap to clear"),
                        onTap: () { _storageOnTap(context); },
                    ),

                    new ListTile(
                        leading: const Icon(Icons.cloud_download),
                        title: const Text("Allow downloads only on Wi-Fi"),
                        trailing: new Switch(
                            value: true, // TODO
                            onChanged: _downloadSwitchChanged,
                        )
                    ),

                    new ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text("About"),
                        onTap: _aboutOnTap,
                    ),
                ],
            ),
        );
    }
}
