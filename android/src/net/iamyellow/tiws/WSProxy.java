//
//   Copyright 2012 jordi domenech <jordi@iamyellow.net>
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

package net.iamyellow.tiws;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.TiContext.OnLifecycleEvent;
import org.appcelerator.titanium.TiBlob;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.text.TextUtils;

import com.codebutler.android_websockets.WebSocketClient;

@Kroll.proxy(creatableInModule = TiwsModule.class)
public class WSProxy extends KrollProxy implements OnLifecycleEvent {
	private WebSocketClient client;
	private boolean connected = false;

	// Constructor
	public WSProxy() {
		super();
	}

	// Websocket stuff
	private void cleanup() {
		if (client == null || !connected) {
			return;
		}

		connected = false;
		try {
			client.disconnect();
		}
		catch (Exception ex) {
		}
		client = null;

		if (TiwsModule.DBG) {
			Log.d(TiwsModule.LCAT, "* websocket destroyed");
		}
	}

	// Context Lifecycle events
	@Override
	public void onStart(Activity activity) {
	}

	@Override
	public void onStop(Activity activity) {
	}

	@Override
	public void onPause(Activity activity) {
	}

	@Override
	public void onResume(Activity activity) {
	}

	@Override
	public void onDestroy(Activity activity) {
		cleanup();
	}

	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict options) {
		super.handleCreationDict(options);
	}

	// Methods

	@Kroll.method
	public void open(Object[] args) {
		final KrollProxy self = this;

		if (args.length == 0) {
			throw new IllegalArgumentException("URI argument expected");
		}

		Object uri = args[0];
		if (!(uri instanceof String)) {
			throw new IllegalArgumentException("URI argument must be a string");
		}
		String wsUri = (String)uri;
		List<BasicNameValuePair> extraHeaders = new ArrayList<BasicNameValuePair>();
		if (args.length > 1) {
			Object proto = args[1];
			if (!(proto instanceof Object[])) {
				throw new IllegalArgumentException("protocols argument must be an array of strings");
			}
			Object[] protocols = (Object[])proto;
			for (int i = 0; i < protocols.length; i++) {
				if (!(protocols[i] instanceof String)) {
					throw new IllegalArgumentException("protocol at index " + i + " is not a string");
				}
			}
			BasicNameValuePair protocolHeader = new BasicNameValuePair("Sec-WebSocket-Protocol", TextUtils.join(", ", protocols));
			extraHeaders.add(protocolHeader);
		}
		try {
			if (TiwsModule.DBG) {
				Log.d(TiwsModule.LCAT, "* creating websocket");
			}

			URI wsURI = new URI(wsUri);
			Log.d(TiwsModule.LCAT, "* URI: " + wsURI);
			client = new WebSocketClient(wsURI, new WebSocketClient.Listener() {
				@Override
				public void onMessage(byte[] data) {
					if (client == null) {
						return;
					}

					KrollDict event = new KrollDict();
					event.put("data", TiBlob.blobFromData(data));
					self.fireEvent("message", event);
				}

				@Override
				public void onMessage(String message) {
					if (client == null) {
						return;
					}

					KrollDict event = new KrollDict();
					event.put("data", message);
					self.fireEvent("message", event);
				}

				@Override
				public void onError(Exception error) {
					if (client == null) {
						return;
					}

					if (TiwsModule.DBG) {
						Log.d(TiwsModule.LCAT, "* websocket error", error);
					}

					KrollDict event = new KrollDict();
					event.put("advice", "reconnect");
					event.put("error", error.toString());
					self.fireEvent("error", event);

					cleanup();
				}

				@Override
				public void onDisconnect(int code, String reason) {
					if (client == null) {
						return;
					}

					if (TiwsModule.DBG) {
						Log.d(TiwsModule.LCAT, "* creating disconnected; reason = " + reason + "; code = " + String.valueOf(code));
					}
					KrollDict event = new KrollDict();
					event.put("code", code);
					event.put("reason", reason);
					self.fireEvent("close", event);

					cleanup();
				}

				@Override
				public void onConnect() {
					connected = true;

					KrollDict event = new KrollDict();
					self.fireEvent("open", event);
				}
			}, extraHeaders);

			client.connect();
		}
		catch (URISyntaxException ex) {
			if (TiwsModule.DBG) {
				Log.d(TiwsModule.LCAT, "* creating exception", ex);
			}
			cleanup();
		}
	}

	@Kroll.method
	public void close() {
		cleanup();
	}
	
	
	@Kroll.method
	public void reconnect(Object[] args) {
		cleanup();
		open(args);
	}

	@Kroll.method
	public void send(String message) {
		if (client != null && connected) {
			client.send(message);
		}
	}
}
