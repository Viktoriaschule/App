package app.viktoria.schule.frame;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FramePlugin implements FlutterPlugin, MethodCallHandler {
    private static MethodChannel channel;
    private FlutterPluginBinding flutterPluginBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        flutterPluginBinding = binding;
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "frame");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Channel[] channels = new Channel[]{
                        new Channel("substitution plan", "Vertretungsplan", "Änderungen für deinen Vertretungsplan"),
                        new Channel("cafetoria", "Cafetoria", "Neue Cafetoriamenüs"),
                        new Channel("aixformation", "AiXformation", "Neuer AiXformationartikel"),
                        new Channel("timetable", "Stundenplan", "Neuer Stundenplan"),
                };
                NotificationManager notificationManager = (NotificationManager) flutterPluginBinding.getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);
                for (int i = 0; i < channels.length; i++) {
                    int importance = i == 0 ? NotificationManager.IMPORTANCE_HIGH : NotificationManager.IMPORTANCE_DEFAULT;
                    NotificationChannel channel = new NotificationChannel(channels[i].name, channels[i].title, importance);
                    channel.setDescription(channels[i].description);
                    channel.setVibrationPattern(new long[]{500, 500});
                    channel.enableVibration(true);
                    channel.enableLights(true);
                    channel.setLightColor(0xFF00FF00);
                    if (notificationManager != null) {
                        notificationManager.createNotificationChannel(channel);
                    }
                }
            }
            result.success("");
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}

class Channel {
    String name;
    String title;
    String description;

    public Channel(String name, String title, String description) {
        this.name = name;
        this.title = title;
        this.description = description;
    }
}