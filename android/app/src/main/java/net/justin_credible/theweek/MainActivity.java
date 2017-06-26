package net.justin_credible.theweek;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "net.justin_credible.theweek.content_manager_plugin";
    private ContentManagerPlugin contentManagerPlugin = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        contentManagerPlugin = new ContentManagerPlugin(this);

        MethodChannel channel = new MethodChannel(getFlutterView(), CHANNEL);

        channel.setMethodCallHandler(
            new MethodCallHandler() {
                @Override
                public void onMethodCall(MethodCall call, Result result) {

                    boolean handled = contentManagerPlugin.execute(call, result);

                    if (!handled) {
                        result.notImplemented();
                    }
                }
            });
    }
}
