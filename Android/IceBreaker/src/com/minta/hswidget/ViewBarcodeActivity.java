package com.minta.hswidget;

import android.app.Activity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class ViewBarcodeActivity extends Activity {
	private TextView valueTitle;
	private BarcodeView barcodeView;
	private RelativeLayout parent;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.view_barcode);

		valueTitle = (TextView) findViewById(R.id.value_title);

		parent = (RelativeLayout) findViewById(R.id.parent);

		DisplayMetrics dm = getResources().getDisplayMetrics();

		// int width = (int) dm.widthPixels - (int) getPixels(20);
		// int height = (int) getPixels(480);

		Bundle extras = getIntent().getExtras();

		if (extras != null) {
			int value = extras.getInt("value");

			valueTitle.setText("$" + value);

			barcodeView = new BarcodeView(this, value, dm.densityDpi,
					dm.heightPixels, dm.widthPixels);

			RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
					dm.widthPixels, dm.heightPixels);
			params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
			params.topMargin = 30;
			params.leftMargin = (dm.widthPixels / 2) - 175;

			barcodeView.setLayoutParams(params);
			barcodeView.invalidate();

			parent.addView(barcodeView);
		}

	}

	/*
	 * private float getPixels(int dp) { return ((dp * density) + 0.5f); }
	 */
}
