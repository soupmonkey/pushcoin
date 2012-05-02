package com.minta.hswidget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.RectF;
import android.util.Log;
import android.widget.ImageView;

import com.onbarcode.barcode.android.AndroidColor;
import com.onbarcode.barcode.android.IBarcode;
import com.onbarcode.barcode.android.QRCode;

@SuppressWarnings("unused")
public class BarcodeView extends ImageView {
	private static final String TAG = "BarcodeView";
	private int value;
	private int dpi;
	
	private int height;
	private int width;

	public BarcodeView(Context context, int value, int dpi,
			int height, int width) {
		super(context);

		this.value = value;
		this.dpi = dpi;
		this.height = height;
		this.width = width;
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);

		Log.d(TAG, canvas.getWidth() + ", " + canvas.getHeight());

		QRCode barcode = new QRCode();
		barcode.setData("$" + value);
		barcode.setDataMode(QRCode.M_AUTO);
		barcode.setVersion(10);
		barcode.setEcl(QRCode.ECL_M);

		// if you want to encode GS1 compatible QR Code, you need set FNC1 mode
		// to IBarcode.FNC1_ENABLE
		barcode.setFnc1Mode(IBarcode.FNC1_NONE);

		// Set the processTilde property to true, if you want use the tilde
		// character "~" to
		// specify special characters in the input data. Default is false.
		// 1-byte character: ~ddd (character value from 0 ~ 255)
		// ASCII (with EXT): from ~000 to ~255
		// 2-byte character: ~6ddddd (character value from 0 ~ 65535)
		// Unicode: from ~600000 to ~665535
		// ECI: from ~7000000 to ~7999999
		// SJIS: from ~9ddddd (Shift JIS 0x8140 ~ 0x9FFC and 0xE040 ~ 0xEBBF)
		barcode.setProcessTilde(false);

		// unit of measure for X, Y, LeftMargin, RightMargin, TopMargin,
		// BottomMargin
		barcode.setUom(IBarcode.UOM_PIXEL);
		// barcode module width in pixel
		barcode.setX(6.5f);

		// barcode image resolution in dpi
		barcode.setResolution(dpi);

		// barcode bar color and background color in Android device
		barcode.setForeColor(AndroidColor.black);
		barcode.setBackColor(AndroidColor.white);

		/*
		 * specify barcode drawing area
		 */
		RectF bounds = new RectF(0, 0, 0, 0);
		try {
			barcode.drawBarcode(canvas, bounds);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
