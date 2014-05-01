% Copyright (c) 2014, Dmitry Kataskin
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
% list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% * Neither the name of the {organization} nor the names of its
% contributors may be used to endorse or promote products derived from
% this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-module(toppage_handler).
-author("Dmitry Kataskin").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
  {ok, Req, undefined}.

handle(Req, State) ->
  Body = <<"
<!DOCTYPE html>
<html lang=\"en\">
<head>
	<meta charset=\"utf-8\">
	<title>Bullet Clock</title>
</head>

<body>
	<p><input type=\"checkbox\" checked=\"yes\" id=\"enable_best\"></input>
		Current time (best source): <span id=\"time_best\">unknown</span>
		<span></span><span id=\"status_best\">unknown</span>
		<button id=\"send_best\">Send Time</button></p>
	<p><input type=\"checkbox\" checked=\"yes\" id=\"enable_websocket\"></input>
		Current time (websocket only): <span id=\"time_websocket\">unknown</span>
		<span></span><span id=\"status_websocket\">unknown</span>
		<button id=\"send_websocket\">Send Time</button></p>
	<p><input type=\"checkbox\" checked=\"yes\" id=\"enable_eventsource\"></input>
		Current time (eventsource only): <span id=\"time_eventsource\">unknown</span>
		<span></span><span id=\"status_eventsource\">unknown</span>
		<button id=\"send_eventsource\">Send Time</button></p>
	<p><input type=\"checkbox\" checked=\"yes\" id=\"enable_polling\"></input>
		Current time (polling only): <span id=\"time_polling\">unknown</span>
		<span></span><span id=\"status_polling\">unknown</span>
		<button id=\"send_polling\">Send Time</button></p>

	<script
		src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\">
	</script>
	<script src=\"/static/bullet.js\"></script>
	<script type=\"text/javascript\">
// <![CDATA[
$(document).ready(function(){
	var start = function(name, options) {
		var bullet;
		var open = function(){
			bullet = $.bullet('ws://localhost:8080/bullet', options);
			bullet.onopen = function(){
				$('#status_' + name).text('online');
			};
			bullet.onclose = bullet.ondisconnect = function(){
				$('#status_' + name).text('offline');
			};
			bullet.onmessage = function(e){
				if (e.data != 'pong'){
					$('#time_' + name).text(e.data);
				}
			};
			bullet.onheartbeat = function(){
				console.log('ping: ' + name);
				bullet.send('ping: ' + name);
			};
		}
		open();
		$('#enable_' + name).on('change', function(){
			if (this.checked){
				open();
			} else{
				bullet.close();
				bullet = null;
			}
		});
		$('#send_' + name).on('click', function(){
			if (bullet) {
				bullet.send('time: ' + name + ' '
					+ $('#time_' + name).text());
			}
		});
	};

	start('best', {});
	start('websocket', {'disableEventSource': true,
		'disableXHRPolling': true});
	start('eventsource', {'disableWebSocket': true,
		'disableXHRPolling': true});
	start('polling', {'disableWebSocket': true,
		'disableEventSource': true});
});
// ]]>
	</script>
</body>
</html>
">>,
  {ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}],
    Body, Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.