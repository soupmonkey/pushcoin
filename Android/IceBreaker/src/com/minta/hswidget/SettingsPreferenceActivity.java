package com.minta.hswidget;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class SettingsPreferenceActivity extends PreferenceActivity {

	@Override
	protected void onCreate(Bundle SavedInstanceState) {
		super.onCreate(SavedInstanceState);
		addPreferencesFromResource(R.xml.setting);

	}

}
