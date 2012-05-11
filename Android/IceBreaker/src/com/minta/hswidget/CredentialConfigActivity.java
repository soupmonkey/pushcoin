package com.minta.hswidget;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;

public class CredentialConfigActivity extends Activity implements
		OnClickListener {

	private static final String TAG = "CredentialConfigActivity";
	private SharedPreferences prefs;
	private SharedPreferences.Editor editor;
	private EditText user_name, passwd;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);

		prefs = getSharedPreferences("minta_hswidget", MODE_PRIVATE);
		editor = prefs.edit();
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		setContentView(R.layout.username_passwd);

		user_name = (EditText) findViewById(R.id.edit_username);
		passwd = (EditText) findViewById(R.id.edit_passwd);

		Button ok = (Button) findViewById(R.id.btn_ok);
		ok.setOnClickListener(this);

		Button cancel = (Button) findViewById(R.id.btn_cancel);
		cancel.setOnClickListener(this);

	}

	public void onClick(View v) {

		switch (v.getId()) {

		case R.id.btn_ok:

			String username = user_name.getText().toString();
			String password = passwd.getText().toString();
			editor.putString("username", username);
			editor.putString("password", password);
			editor.commit();

		case R.id.btn_cancel:

			finish();

			break;
		}

	}
}
