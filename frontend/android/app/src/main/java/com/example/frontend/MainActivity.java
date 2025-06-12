package com.example.frontend;

import io.flutter.embedding.android.FlutterActivity;

import android.app.usage.UsageEvents;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.Calendar;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "app_usage_channel";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getHourlyAppUsage")) {
                        Long startMillisObj = call.argument("start");
                        Long endMillisObj = call.argument("end");

                        long startMillis = (startMillisObj != null) ? startMillisObj.longValue() : 0L;
                        long endMillis = (endMillisObj != null) ? endMillisObj.longValue() : 0L;

                        Map<String, Map<String, List<Integer>>> usage = getDailyHourlyAppUsage(startMillis, endMillis);
                        result.success(usage);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private Map<String, Map<String, List<Integer>>> getDailyHourlyAppUsage(long startMillis, long endMillis) {
        UsageStatsManager usm = (UsageStatsManager) getSystemService(Context.USAGE_STATS_SERVICE);
        UsageEvents events = usm.queryEvents(startMillis, endMillis);
        UsageEvents.Event event = new UsageEvents.Event();

        Map<String, Long> currentSessions = new HashMap<>();
        Map<String, Map<String, List<long[]>>> sessionMap = new HashMap<>();

        while (events.hasNextEvent()) {
            events.getNextEvent(event);
            String packageName = event.getPackageName();
            long timestamp = event.getTimeStamp();

            if (event.getEventType() == UsageEvents.Event.ACTIVITY_RESUMED ||
                    event.getEventType() == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                currentSessions.put(packageName, timestamp);
            } else if (event.getEventType() == UsageEvents.Event.ACTIVITY_PAUSED ||
                    event.getEventType() == UsageEvents.Event.MOVE_TO_BACKGROUND) {
                Long start = currentSessions.remove(packageName);
                if (start != null && timestamp > start) {
                    Calendar cal = Calendar.getInstance();
                    cal.setTimeInMillis(start);
                    String day = String.format("%04d-%02d-%02d",
                            cal.get(Calendar.YEAR),
                            cal.get(Calendar.MONTH) + 1,
                            cal.get(Calendar.DAY_OF_MONTH));

                    sessionMap
                            .computeIfAbsent(packageName, k -> new HashMap<>())
                            .computeIfAbsent(day, k -> new ArrayList<>())
                            .add(new long[]{start, timestamp});
                }
            }
        }

        Map<String, Map<String, List<Integer>>> result = new HashMap<>();

        for (Map.Entry<String, Map<String, List<long[]>>> appEntry : sessionMap.entrySet()) {
            String packageName = appEntry.getKey();
            Map<String, List<long[]>> dailySessions = appEntry.getValue();

            Map<String, List<Integer>> dailyHourly = new HashMap<>();

            for (Map.Entry<String, List<long[]>> dayEntry : dailySessions.entrySet()) {
                String date = dayEntry.getKey();
                List<long[]> sessions = dayEntry.getValue();

                List<Integer> hourlyUsage = new ArrayList<>();
                for (int i = 0; i < 24; i++) hourlyUsage.add(0);

                int totalDailyUsage = 0;

                for (long[] session : sessions) {
                    Calendar cal = Calendar.getInstance();
                    cal.setTimeInMillis(session[0]);
                    int hour = cal.get(Calendar.HOUR_OF_DAY);

                    int duration = (int) ((session[1] - session[0]) / 1000);
                    hourlyUsage.set(hour, hourlyUsage.get(hour) + duration);
                    totalDailyUsage += duration;
                }

                if (totalDailyUsage > 0) {
                    dailyHourly.put(date, hourlyUsage);
                }
            }

            if (!dailyHourly.isEmpty()) {
                result.put(packageName, dailyHourly);
            }
        }

        return result;
    }
}