package app.viktoria.schule.frame;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Html;
import android.text.SpannableString;
import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import java.util.HashMap;
import java.util.Map;

public class FramePlugin implements FlutterPlugin, MethodCallHandler {
    private static MethodChannel channel;
    private Context applicationContext;
    public static OnLaunchCallback onLaunchCallback;


    public static void registerWith(PluginRegistry.Registrar registrar) {
        FramePlugin instance = new FramePlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    private void onAttachedToEngine(Context context, BinaryMessenger binaryMessenger) {
        this.applicationContext = context;
        channel = new MethodChannel(binaryMessenger, "frame");
        channel.setMethodCallHandler(this);
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachedToEngine(
                binding.getApplicationContext(), binding.getFlutterEngine().getDartExecutor());
    }

    @SuppressWarnings({"unchecked", "ConstantConditions", "deprecation"})
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            onLaunchCallback.onLaunch();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Channel[] channels = new Channel[]{
                        new Channel("substitution plan", "Vertretungsplan", "Änderungen für deinen Vertretungsplan"),
                        new Channel("cafetoria", "Cafetoria", "Neue Cafetoriamenüs"),
                        new Channel("aixformation", "AiXformation", "Neuer AiXformationartikel"),
                        new Channel("timetable", "Stundenplan", "Neuer Stundenplan"),
                };
                NotificationManager notificationManager = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
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
        } else if (call.method.equals("notification")) {
            try {
                Map<String, Object> data = (Map<String, Object>) call.arguments;

                Intent intent = new Intent(applicationContext, Class.forName(applicationContext.getPackageName() + ".MainActivity"));
                for (int i = 0; i < data.keySet().size(); i++) {
                    String key = data.keySet().toArray()[i].toString();
                    intent.putExtra(key, String.valueOf(data.get(key)));
                }

                int uniqueInt = (int) (System.currentTimeMillis() & 0xfffffff);
                PendingIntent pendingIntent = PendingIntent.getActivity(applicationContext, uniqueInt, intent, PendingIntent.FLAG_CANCEL_CURRENT);

                String title = (String) data.get("title");
                String body = (String) data.get("body");
                String bigBody = (String) data.get("bigBody");
                int group = (int) data.get("group");
                SpannableString formattedBody = new SpannableString(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.N ? Html.fromHtml(body)
                                : Html.fromHtml(body, Html.FROM_HTML_MODE_LEGACY));
                SpannableString formattedBigBody = new SpannableString(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.N ? Html.fromHtml(bigBody)
                                : Html.fromHtml(bigBody, Html.FROM_HTML_MODE_LEGACY));
                PackageManager packageManager = applicationContext.getPackageManager();
                Resources resources = packageManager.getResourcesForApplication(applicationContext.getPackageName());
                int resId = resources.getIdentifier(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ? "ic_launcher" : "logo_white", "mipmap", applicationContext.getPackageName());

                NotificationCompat.Builder notification = new NotificationCompat.Builder(applicationContext, String.valueOf(group))
                        .setContentTitle(title).setContentText(formattedBody)
                        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                        .setStyle(new NotificationCompat.BigTextStyle().bigText(formattedBigBody))
                        .setSmallIcon(resId)
                        .setContentIntent(pendingIntent).setTicker(title + " " + formattedBody)
                        .setColor(Color.parseColor("#ff5bc638")).setGroup(String.valueOf(group)).setAutoCancel(true)
                        .setColorized(true);

                NotificationManagerCompat.from(applicationContext).notify(group, notification.build());
            } catch (ClassNotFoundException | PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
            result.success("");
        } else {
            result.notImplemented();
        }
    }

    public static boolean sendMessageFromIntent(DartExecutor dartExecutor, String method, Intent intent) {
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