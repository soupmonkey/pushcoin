package com.minta.hswidget;

import android.app.IntentService;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.widget.RemoteViews;

public class UpdateService extends IntentService {
	private static final String TAG = "UpdateService";
	
	public UpdateService() {
		super("UpdateService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		Log.d(TAG, "onStart");

		ComponentName me = new ComponentName(this, HSWidgetProvider.class);
		AppWidgetManager mgr = AppWidgetManager.getInstance(this);
		int appWidgetId = -1;

		Bundle extras = intent.getExtras();
		if (extras != null) {

			Log.d(TAG, "Extras: " + intent.getExtras().keySet());

			appWidgetId = extras.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID);
			Log.d(TAG, "appWidgetId: " + appWidgetId);
		}

		updateAppWidget(this, mgr, me, 0, appWidgetId);
	}

	static void updateAppWidget(Context context,
			AppWidgetManager appWidgetManager, ComponentName comp, int configValue, int configWidgetId) {
		
		SharedPreferences prefs = context.getSharedPreferences("minta_hswidget", MODE_PRIVATE);
		
		int[] appWidgetIds = appWidgetManager.getAppWidgetIds(comp);
    	int length = appWidgetIds.length;
    	
    	for(int j=0; j<length; j++){
		
    		int appWidgetId = appWidgetIds[j];
    		int value = prefs.getInt("widget"+appWidgetId, -1);
    		
    		if(value<0){
    			value = configValue;
    			appWidgetId = configWidgetId;
    		}
		
    		Log.d(TAG, "updateAppWidget");

    		RemoteViews views = new RemoteViews(context.getPackageName(),
				R.layout.widget_one);
    		views.setTextViewText(R.id.text, "$" + value);

    		Intent i = new Intent(context, ViewBarcodeActivity.class);
    		i.putExtra("value", value);
    		PendingIntent pi = PendingIntent.getActivity(context,
				(int) System.currentTimeMillis(), i,
				PendingIntent.FLAG_UPDATE_CURRENT);

    		views.setOnClickPendingIntent(R.id.text, pi);

    		appWidgetManager.updateAppWidget(appWidgetId, views);
    	}

	}
}
