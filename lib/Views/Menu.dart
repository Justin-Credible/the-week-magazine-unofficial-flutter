
import "package:flutter/widgets.dart";
import "package:flutter/material.dart";

class Menu extends StatefulWidget {
    Menu({Key key}) : super(key: key);

    @override
    _MenuState createState() => new _MenuState();
}

class _MenuState extends State<Menu> {

    void _issuesOnTap() {
        // TODO
    }

    void _storageOnTap() {
        // TODO
    }

    void _downloadSwitchChanged(bool value) {
        // TODO
    }

    void _aboutOnTap() {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/about");
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
                        trailing: const Text("32MB"), // TODO
                        subtitle: const Text("Calculating..."), // TODO
                        onTap: _storageOnTap,
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
