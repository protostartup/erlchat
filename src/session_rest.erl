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

-module(session_rest).
-author("Dmitry Kataskin").

-include("erlchat.hrl").

-define(input_not_json, <<"Input wasn't in a valid application/json format">>).
-define(input_not_session, <<"Input wasn't a valid session object">>).

%% rest handler callbacks
-export([init/3, allowed_methods/2, content_types_accepted/2, content_types_provided/2]).

%% custom callbacks
-export([init_session/2, get_session/2]).

init(_Transport, _Req, []) ->
                {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
                {[<<"GET">>, <<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
                {[{<<"application/json">>, init_session}], Req, State}.

content_types_provided(Req, State) ->
                {[{<<"application/json">>, get_session}], Req, State}.

init_session(Req, State) ->
                {ok, Body, Req1} = cowboy_req:body_qs(Req),
                case parse_session(Body, Req1, State) of
                  {ok, {SessionId, UserId}} ->
                    {initiated, Session} = erlchat_sessions:init_session(UserId, SessionId),
                    {ok, Req2} = cowboy_req:reply(201, [], session_to_json(Session), Req1),
                    {ok, Req2, State};

                  {error, Response} ->
                    Response
                end.

get_session(Req, State) -> ok.

parse_session([], Req, State) ->
                {error, error_response(bad_request, ?input_not_json, Req, State)};

parse_session([{Body, true}], Req, State) ->
                case jsx:is_json(Body) of
                  true ->
                    Session = jsx:decode(Body),
                    case Session of
                      [{<<"user_id">>, UserId}, {<<"session_id">>, SessionId}] ->
                        {ok, {SessionId, UserId}};

                      _ ->
                        {error, error_response(bad_request, ?input_not_session, Req, State)}
                    end;

                  false ->
                    {error, error_response(bad_request, ?input_not_json, Req, State)}
                end;

parse_session(_, Req, State) ->
                {error, error_response(bad_request, ?input_not_json, Req, State)}.

session_to_json(#erlchat_session { id = SessionId, user_id = UserId }) ->
                jsx:encode([{status, ok}, {user_id, UserId}, {session_id, SessionId}]).

error_response(bad_request, Message, Req, State) ->
                Json = jsx:encode([{error, [{reason, Message}]}]),
                {ok, Req1} = cowboy_req:reply(400, [], Json, Req),
                {ok, Req1, State}.