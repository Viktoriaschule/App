package app.viktoria.schule;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    static final String CHANNEL = "app.viktoria.schule";
    static DartExecutor dartExecutor;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        dartExecutor = flutterEngine.getDartExecutor();

        boolean[] registered = new boolean[]{false};

        new MethodChannel(dartExecutor, CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals("channel_registered")) {
                if (registered[0]) {
                    result.success(null);
                    return;
                }
                registered[0] = true;
                result.success(sendMessageFromIntent("onLaunch", getIntent()));
            }
        });
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Channel[] channels = new Channel[]{
                    new Channel("substitution plan", "Vertretungsplan", "Änderungen für deinen Vertretungsplan"),
                    new Channel("cafetoria", "Cafetoria", "Neue Cafetoriamenüs"),
                    new Channel("aixformation", "AiXformation", "Neuer AiXformationartikel"),
                    new Channel("timetable", "Stundenplan", "Neuer Stundenplan"),
            };
            NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
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
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        sendMessageFromIntent("onResume", intent);
    }

    static boolean sendMessageFromIntent(String method, Intent intent) {
        Bundle extras = intent.getExtras();

        if (extras == null || extras.get("type") == null) {
            return false;
        }

        Map<String, Object> data = new HashMap<>();

        for (String key : extras.keySet()) {
            Object extra = extras.get(key);
            if (extra != null) {
                data.put(key, extra);
            }
        }
        new Handler(Looper.getMainLooper()).post(() -> new MethodChannel(dartExecutor, "plugins.flutter.io/firebase_messaging").invokeMethod(method, data));
        return true;
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