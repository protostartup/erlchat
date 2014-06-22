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
% * Neither the name of the erlchat nor the names of its
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

-module(erlchat_session_manager).
-author("Dmitry Kataskin").

-include("erlchat.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([get_events/1]).
-export([start_topic/4]).
-export([send_message/3]).

%% gen_serve callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% API
start_link() ->
        gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

get_events(SessionId) ->
        gen_server:call({local, ?MODULE}, {get_events, SessionId}).

start_topic(SessionId, Users, Subject, Text) ->
        ok.

send_message(SessionId, TopicId, Text) ->
        ok.

%% gen_serve callbacks
init(_Args) ->
        {ok, no_state}.

handle_call({get_events, SessionId}, _From, State) ->
        Session = erlchat_sessions:get_session(SessionId),
        Sessions = erlchat_sessions:get_user_sessions(Session#erlchat_session.user_id),
        {reply, [], State}.

handle_cast(Request, State) ->
        {noreply, state}.

handle_info(Info, State) ->
        erlang:error(not_implemented).

terminate(Reason, State) ->
        erlang:error(not_implemented).

code_change(OldVsn, State, Extra) ->
        erlang:error(not_implemented).
