# tiws Module

## Description

tiws is a very simple Titanium module (iOS / Android) for creating native websockets.
it is also possible use tiws with Socket.IO and Now.js, check it out here!
https://gist.github.com/3071689

tiws is open source (https://github.com/iamyellow/tiws) and uses third parties websocket implementations:

* for iOS, SocketRocket:
https://github.com/square/SocketRocket/

* for Android
https://github.com/codebutler/android-websockets

## Accessing the tiws Module

To access this module from JavaScript, you would do the following:

	var tiws = require("net.iamyellow.tiws");

The tiws variable is a reference to the Module object.

## Module functions

### createWS

Creates a websocket object.

## Websocket object functions

### open (string uri[, string protocol])

Given an URI, opens the connection. Optionally, an additional string argument can be used to specify the subprotocol

### send (string message)

Sends a string message.

### close ()

Closes a previously opened connection.

## Websocket events

You can add listeners for events: 'open', 'close', 'error' and 'message'.

## Usage

https://gist.github.com/3071689

## Author

jordi domenech
jordi@iamyellow.net
http://iamyellow.net
@iamyellow2

## Feedback and Support

jordi@iamyellow.net

## License

### tiws

Copyright 2012 jordi domenech <jordi@iamyellow.net>
Apache License, Version 2.0

### Socket.IO

Copyright(c) 2011 LearnBoost <dev@learnboost.com>
MIT Licensed

### Now.js

Copyright (C) 2011 by Flotype Inc. <team@nowjs.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE