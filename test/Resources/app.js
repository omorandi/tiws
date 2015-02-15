// ****************************************************************************************************************
// ****************************************************************************************************************
// test value can be 'raw' | 'socket.io' | 'nowjs'

var test = 'raw',

// ****************************************************************************************************************
// ****************************************************************************************************************
// REMEMBER to change this with your data

uri = 'ws://ws.websocketstest.com:80/service';

// ****************************************************************************************************************
// ****************************************************************************************************************
// example using a plain websockets

if ('raw' === test) {
	var WS = require('net.iamyellow.tiws').createWS();

	WS.addEventListener('open', function () {
		Ti.API.debug('ws opened');
	});

	WS.addEventListener('close', function (e) {
		Ti.API.info("ws closed - code: " + e.code + " reason: " + e.reason);
	});

	WS.addEventListener('error', function (e) {
		Ti.API.error("Got error: " + e.error);
	});

    var proto_version;
    var stream_cnt = 0;

	WS.addEventListener('message', function (e) {
		Ti.API.log("Got message: " + e.data);
        arr = e.data.split(',',2);
        cmd = arr[0];
        response = arr[1];

        if (cmd == 'connected') {
          Ti.API.log("got response: " + response);
          WS.send("version,");
        }
        else if (cmd == 'version') {
          Ti.API.log("got response: " + response);
          proto_version = response;
          WS.send("echo,test message");
        }
        else if (cmd == 'echo' && response == 'test message') {
          Ti.API.log("got response: " + response);
          if (proto_version == 'hybi-draft-07') {
            WS.send("ping,");
          }
          else {
            WS.send("timer,");
          }
        }
        else if (cmd == 'time') {
          stream_cnt = stream_cnt + 1;
          Ti.API.log("got response: " + response);
          if (stream_cnt > 3) {
            WS.close();
            alert('looks good');
          }
        }
	});

	WS.open(uri, ["echo-protocol", "other-proto"]);
}

// ****************************************************************************************************************
// ****************************************************************************************************************
// example using socket.io which uses websocket

else if ('socket.io' === test) {
	var io = require('socket.io'),
	socket = io.connect(uri);

	socket.on('connect', function () {
		Ti.API.log('connected!')
	});
}

// ****************************************************************************************************************
// ****************************************************************************************************************
// example using now.js which uses socket.io which uses websockets

else if ('nowjs' === test) {
	var now = require('now').nowInitialize(uri, {
		// socket.io init options
		socketio: {
			transports: ['websocket']
		}
	});

	now.core.on('error', function () {
		Ti.API.error('error!')
	});

	now.core.on('ready', function () {
		Ti.API.log('now is now ready')
	});

	now.core.on('disconnect', function () {
		Ti.API.log('now disconnected');
	});

	// now data bindings
	now.userID = '4815162342';
	now.whatLiesInTheShadowOfTheStatue = function () {
		return 'ille qui nos omnes servabit';
	};
}
