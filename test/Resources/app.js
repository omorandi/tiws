// ****************************************************************************************************************
// ****************************************************************************************************************
// test value can be 'raw' | 'socket.io' | 'nowjs'

var test = 'raw',

// ****************************************************************************************************************
// ****************************************************************************************************************
// REMEMBER to change this with your data

uri = 'ws://<YOUR IP>:8080';

// ****************************************************************************************************************
// ****************************************************************************************************************
// example using a plain websockets

if ('raw' === test) {
	var WS = require('net.iamyellow.tiws').createWS();

	WS.addEventListener('open', function () {
		Ti.API.debug('ws opened sending hello');
		WS.send("hello");
	});

	WS.addEventListener('close', function (e) {
		Ti.API.info("ws closed - code: " + e.code + " reason: " + e.reason);
	});

	WS.addEventListener('error', function (e) {
		Ti.API.error("Got error: " + e.error);
	});

	WS.addEventListener('message', function (e) {
		Ti.API.log("Got message: " + e.data);
	});

	WS.open(uri, "echo-protocol");
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