/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package org.audreyt.dict.moe;

import android.os.Bundle;
import android.view.*;
import org.apache.cordova.*;

public class MoeDict extends CordovaActivity 
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        super.init();
        // Set by <content src="index.html" /> in config.xml
        super.setIntegerProperty("splashscreen", R.drawable.splash);
        super.loadUrl(Config.getStartUrl(), 5000);
        //super.loadUrl("file:///android_asset/www/index.html")
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        this.getMenuInflater().inflate(R.menu.example, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
	if (id == R.id.small) {
	        this.appView.sendJavascript("window.adjustFontSize(-1)");
        }
        else if (id == R.id.large) {
	        this.appView.sendJavascript("window.adjustFontSize(+1)");
        }
        else if (id == R.id.quit) {
                this.appView.sendJavascript("window.pressQuit()");
        }
        else if (id == R.id.lang) {
                this.appView.sendJavascript("window.pressLang()");
        }
        else {
                return super.onOptionsItemSelected(item);
        }
        return true;
    }
}

