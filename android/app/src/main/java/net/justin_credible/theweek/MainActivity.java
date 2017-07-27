package net.justin_credible.theweek;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "net.justin_credible.theweek.content_manager_plugin";
    private ContentManagerPlugin contentManagerPlugin = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        MethodChannel channel = new MethodChannel(getFlutterView(), CHANNEL);
        contentManagerPlugin = new ContentManagerPlugin(this, channel);
    }
}
