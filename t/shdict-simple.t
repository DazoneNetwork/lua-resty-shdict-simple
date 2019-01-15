# vi:ft=

use Test::Nginx::Socket::Lua;

repeat_each(2);
no_long_string();

plan tests => repeat_each() * (3 * blocks());

our $HttpConfig = <<'_EOC_';
    lua_shared_dict shared 1m;
    lua_package_path 'lib/?.lua;;';
_EOC_

log_level 'debug';

run_tests();

__DATA__

=== TEST 1: sanity
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local shdict_simple = require "resty.shdict.simple"

            local function dlog(ctx, ...)
                ngx.log(ngx.DEBUG, "my app: ", ...)
            end

            local function error_log(ctx, ...)
                ngx.log(ngx.ERR, "my app: ", ...)
            end

            local function warn(ctx, ...)
                ngx.log(ngx.WARN, "my app: ", ...)
            end

            local meta_shdict_set, meta_shdict_get =
                shdict_simple.gen_shdict_methods{
                    dict_name = "shared",
                    debug_logger = dlog,
                    error_logger = error_log,
                    positive_ttl = 24 * 60 * 60 * 1000,     -- in ms
                    negative_ttl = 60 * 60 * 1000,          -- in ms
                }

            local ctx = ngx.ctx
            local key = "c57a769495f14df8985d773eaa410ba2411aa9d588798b3aea60eae29a383ab0"
            local value = string.rep("a", 129)
            ok = meta_shdict_set(ctx, key, value)
            ngx.say(ok)
            local data, err = meta_shdict_get(ctx, key)
            ngx.say(data == value)
        }
    }
--- request
GET /t
--- response_body
true
true
--- no_error_log
[error]



=== TEST 2: max_tries
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local shdict_simple = require "resty.shdict.simple"

            local function dlog(ctx, ...)
                ngx.log(ngx.DEBUG, "my app: ", ...)
            end

            local function error_log(ctx, ...)
                ngx.log(ngx.ERR, "my app: ", ...)
            end

            local function warn(ctx, ...)
                ngx.log(ngx.WARN, "my app: ", ...)
            end

            local meta_shdict_set, meta_shdict_get =
                shdict_simple.gen_shdict_methods{
                    dict_name = "shared",
                    debug_logger = dlog,
                    error_logger = error_log,
                    positive_ttl = 24 * 60 * 60 * 1000,     -- in ms
                    negative_ttl = 60 * 60 * 1000,          -- in ms
                    max_tries = 10,
                }

            local ctx = ngx.ctx
            local key = "a"
            local value = string.rep("a", 1000 * 1000)
            ok = meta_shdict_set(ctx, key, value)
            ngx.say(ok)
            local data, err = meta_shdict_get(ctx, key)
            ngx.say(data == value)

            key = "b"
            value = string.rep("b", 1000 * 1000)
            ok = meta_shdict_set(ctx, key, value)
            ngx.say(ok)
            local data, err = meta_shdict_get(ctx, key)
            ngx.say(data == value)
        }
    }
--- request
GET /t
--- response_body
true
true
true
true
--- error_log
try to set key 1th time



=== TEST 3: use the default value of max_tries
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local shdict_simple = require "resty.shdict.simple"

            local function dlog(ctx, ...)
                ngx.log(ngx.DEBUG, "my app: ", ...)
            end

            local function error_log(ctx, ...)
                ngx.log(ngx.ERR, "my app: ", ...)
            end

            local function warn(ctx, ...)
                ngx.log(ngx.WARN, "my app: ", ...)
            end

            local meta_shdict_set, meta_shdict_get =
                shdict_simple.gen_shdict_methods{
                    dict_name = "shared",
                    debug_logger = dlog,
                    error_logger = error_log,
                    positive_ttl = 24 * 60 * 60 * 1000,     -- in ms
                    negative_ttl = 60 * 60 * 1000,          -- in ms
                }

            local ctx = ngx.ctx
            local key = "a"
            local value = string.rep("a", 1000 * 1000)
            ok = meta_shdict_set(ctx, key, value)
            ngx.say(ok)
            local data, err = meta_shdict_get(ctx, key)
            ngx.say(data == value)

            key = "b"
            value = string.rep("b", 1000 * 1000)
            ok = meta_shdict_set(ctx, key, value)
            ngx.say(ok)
            local data, err = meta_shdict_get(ctx, key)
            ngx.say(data == value)
        }
    }
--- request
GET /t
--- response_body
true
true
true
true
--- error_log
try to set key 1th time
