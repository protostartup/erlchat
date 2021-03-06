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

-module(erlchat_app).
-behaviour(application).

-author("Dmitry Kataskin").

-export([start/2, stop/1]).

start(_Type, _Args) ->
        AuthToken = case application:get_env(erlchat, auth_token) of
                      {ok, Token} -> Token;
                      undefined -> undefined
                    end,

        Dispatch = cowboy_router:compile([
          {'_', [
            static_files("js"),
            static_files("css"),
            static_files("img"),
            {"/", toppage_handler, []},
            {"/sample", erlchat_sample_handler, []},
            {"/session/[:session_id]", erlchat_session_rest, [{auth_token, AuthToken}]},
            {"/erlchat", bullet_handler, [{handler, erlchat_handler}]}
          ]}
        ]),
        {ok, _} = cowboy:start_http(http, 100,
          [{port, 8085}], [{env, [{dispatch, Dispatch}]}]
        ),
        erlchat_sup:start_link().

stop(_State) ->
        ok.

static_files(FileType) ->
        {lists:append(["/", FileType, "/[...]"]), cowboy_static,
          {dir, static_content_dir(FileType), [{mimetypes, cow_mimetypes, web}]}}.

static_content_dir(FileType) ->
        filename:join(erlchat_utils:priv_dir(), FileType).
