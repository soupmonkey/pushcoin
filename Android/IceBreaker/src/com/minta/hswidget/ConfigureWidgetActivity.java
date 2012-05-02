package com.minta.hswidget;

import android.app.Activity;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;

public class ConfigureWidgetActivity extends Activity implements
		OnClickListener {
	
	private static final String TAG = "ConfigureWidgetActivity";
	private int mAppWidgetId = 0;
	private NumberPicker mNumberPicker;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		
		setContentView(R.layout.widget_configure);

		mNumberPicker = (NumberPicker) findViewById(R.id.num_picker);
		mNumberPicker.setRange(5, 1000);
		Button ok = (Button) findViewById(R.id.btn_ok);
		ok.setOnClickListener(this);
		Intent intent = getIntent();
		Bundle extras = intent.getExtras();
		if (extras != null) {
			mAppWidgetId = extras.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID,
					AppWidgetManager.INVALID_APPWIDGET_ID);
		}
	}

	public void onClick(View v) {

		Log.d(TAG, "Current value: " + mNumberPicker.getCurrent());

		Intent resultValue = new Intent();
		resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, mAppWidgetId);
		setResult(RESULT_OK, resultValue);

		AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(this);
		ComponentName comp = new ComponentName(getPackageName(),
				HSWidgetProvider.class.getName());
		UpdateService.updateAppWidget(this, appWidgetManager, comp,
				mAppWidgetId, mNumberPicker.getCurrent());

		finish();
	}
}
