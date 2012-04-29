package com.minta.hswidget;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class HSWidgetProvider extends AppWidgetProvider {
	// log tag
	private static final String TAG = "HSWidgetProvider";
	private int currentAppWidgetId;

	@Override
	public void onReceive(Context context, Intent intent) {

		Log.d(TAG, "onReceived");

		Bundle extras = intent.getExtras();

		if (extras != null) {

			int[] appWidgetIds = extras
					.getIntArray(AppWidgetManager.EXTRA_APPWIDGET_IDS);

			Log.d(TAG, "Extras: " + intent.getExtras().keySet() + ": "
					+ appWidgetIds);

			if (appWidgetIds != null)
				currentAppWidgetId = appWidgetIds[0];
		}

		super.onReceive(context, intent);
	}

	@Override
	public void onUpdate(Context context, AppWidgetManager appWidgetManager,
			int[] appWidgetIds) {
		Log.d(TAG, "onUpdate");

		for (int i = 0; i < appWidgetIds.length; ++i) {
			Log.d(TAG, "id: " + appWidgetIds[i]);
		}

		currentAppWidgetId = appWidgetIds[0];

		Intent i = new Intent(context, UpdateService.class);
		i.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, currentAppWidgetId);
		context.startService(i);
	}

	@Override
	public void onDeleted(Context context, int[] appWidgetIds) {
		Log.d(TAG, "onDeleted");
	}

	@Override
	public void onEnabled(Context context) {
		Log.d(TAG, "onEnabled");

		Intent i = new Intent(context, UpdateService.class);
		i.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, currentAppWidgetId);

		context.startService(i);
	}

	@Override
	public void onDisabled(Context context) {
		Log.d(TAG, "onDisabled");
	}
}
