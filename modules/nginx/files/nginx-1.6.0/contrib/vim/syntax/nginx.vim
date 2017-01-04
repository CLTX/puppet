" Vim syntax file
" Language: nginx.conf

if exists("b:current_syntax")
  finish
end

setlocal iskeyword+=.
setlocal iskeyword+=/
setlocal iskeyword+=:

syn match ngxVariable '\$\(\w\+\|{\w\+}\)'
syn match ngxVariableBlock '\$\(\w\+\|{\w\+}\)' contained
syn match ngxVariableString '\$\(\w\+\|{\w\+}\)' contained
syn region ngxBlock start=+^+ end=+{+ skip=+\${+ contains=ngxComment,ngxappname03iveBlock,ngxVariableBlock,ngxString oneline
syn region ngxString start=+\z(["']\)+ end=+\z1+ skip=+\\\\\|\\\z1+ contains=ngxVariableString
syn match ngxComment ' *#.*$'

syn keyword ngxBoolean on
syn keyword ngxBoolean off

syn keyword ngxappname03iveBlock http         contained
syn keyword ngxappname03iveBlock mail         contained
syn keyword ngxappname03iveBlock events       contained
syn keyword ngxappname03iveBlock server       contained
syn keyword ngxappname03iveBlock types        contained
syn keyword ngxappname03iveBlock location     contained
syn keyword ngxappname03iveBlock upstream     contained
syn keyword ngxappname03iveBlock charset_map  contained
syn keyword ngxappname03iveBlock limit_except contained
syn keyword ngxappname03iveBlock if           contained
syn keyword ngxappname03iveBlock geo          contained
syn keyword ngxappname03iveBlock map          contained

syn keyword ngxappname03iveImportant include
syn keyword ngxappname03iveImportant root
syn keyword ngxappname03iveImportant server
syn keyword ngxappname03iveImportant server_name
syn keyword ngxappname03iveImportant listen
syn keyword ngxappname03iveImportant internal
syn keyword ngxappname03iveImportant proxy_pass
syn keyword ngxappname03iveImportant memcached_pass
syn keyword ngxappname03iveImportant fastcgi_pass
syn keyword ngxappname03iveImportant try_files

syn keyword ngxappname03iveControl break
syn keyword ngxappname03iveControl return
syn keyword ngxappname03iveControl rewrite
syn keyword ngxappname03iveControl set

syn keyword ngxappname03iveError error_page
syn keyword ngxappname03iveError post_action

syn keyword ngxappname03iveDeprecated connections
syn keyword ngxappname03iveDeprecated imap
syn keyword ngxappname03iveDeprecated open_file_cache_retest
syn keyword ngxappname03iveDeprecated optimize_server_names
syn keyword ngxappname03iveDeprecated satisfy_any

syn keyword ngxappname03ive accept_mutex
syn keyword ngxappname03ive accept_mutex_delay
syn keyword ngxappname03ive access_log
syn keyword ngxappname03ive add_after_body
syn keyword ngxappname03ive add_before_body
syn keyword ngxappname03ive add_header
syn keyword ngxappname03ive addition_types
syn keyword ngxappname03ive aio
syn keyword ngxappname03ive alias
syn keyword ngxappname03ive allow
syn keyword ngxappname03ive ancient_browser
syn keyword ngxappname03ive ancient_browser_value
syn keyword ngxappname03ive auth_basic
syn keyword ngxappname03ive auth_basic_user_file
syn keyword ngxappname03ive auth_http
syn keyword ngxappname03ive auth_http_header
syn keyword ngxappname03ive auth_http_timeout
syn keyword ngxappname03ive autoindex
syn keyword ngxappname03ive autoindex_exact_size
syn keyword ngxappname03ive autoindex_localtime
syn keyword ngxappname03ive charset
syn keyword ngxappname03ive charset_types
syn keyword ngxappname03ive client_body_buffer_size
syn keyword ngxappname03ive client_body_in_file_only
syn keyword ngxappname03ive client_body_in_single_buffer
syn keyword ngxappname03ive client_body_temp_path
syn keyword ngxappname03ive client_body_timeout
syn keyword ngxappname03ive client_header_buffer_size
syn keyword ngxappname03ive client_header_timeout
syn keyword ngxappname03ive client_max_body_size
syn keyword ngxappname03ive connection_pool_size
syn keyword ngxappname03ive create_full_put_path
syn keyword ngxappname03ive daemon
syn keyword ngxappname03ive dav_access
syn keyword ngxappname03ive dav_methods
syn keyword ngxappname03ive debug_connection
syn keyword ngxappname03ive debug_points
syn keyword ngxappname03ive default_type
syn keyword ngxappname03ive degradation
syn keyword ngxappname03ive degrade
syn keyword ngxappname03ive deny
syn keyword ngxappname03ive devpoll_changes
syn keyword ngxappname03ive devpoll_events
syn keyword ngxappname03ive appname03io
syn keyword ngxappname03ive appname03io_alignment
syn keyword ngxappname03ive empty_gif
syn keyword ngxappname03ive env
syn keyword ngxappname03ive epoll_events
syn keyword ngxappname03ive error_log
syn keyword ngxappname03ive eventport_events
syn keyword ngxappname03ive expires
syn keyword ngxappname03ive fastcgi_bind
syn keyword ngxappname03ive fastcgi_buffer_size
syn keyword ngxappname03ive fastcgi_buffers
syn keyword ngxappname03ive fastcgi_busy_buffers_size
syn keyword ngxappname03ive fastcgi_cache
syn keyword ngxappname03ive fastcgi_cache_key
syn keyword ngxappname03ive fastcgi_cache_methods
syn keyword ngxappname03ive fastcgi_cache_min_uses
syn keyword ngxappname03ive fastcgi_cache_path
syn keyword ngxappname03ive fastcgi_cache_use_stale
syn keyword ngxappname03ive fastcgi_cache_valid
syn keyword ngxappname03ive fastcgi_catch_stderr
syn keyword ngxappname03ive fastcgi_connect_timeout
syn keyword ngxappname03ive fastcgi_hide_header
syn keyword ngxappname03ive fastcgi_ignore_client_abort
syn keyword ngxappname03ive fastcgi_ignore_headers
syn keyword ngxappname03ive fastcgi_index
syn keyword ngxappname03ive fastcgi_intercept_errors
syn keyword ngxappname03ive fastcgi_max_temp_file_size
syn keyword ngxappname03ive fastcgi_next_upstream
syn keyword ngxappname03ive fastcgi_param
syn keyword ngxappname03ive fastcgi_pass_header
syn keyword ngxappname03ive fastcgi_pass_request_body
syn keyword ngxappname03ive fastcgi_pass_request_headers
syn keyword ngxappname03ive fastcgi_read_timeout
syn keyword ngxappname03ive fastcgi_send_lowat
syn keyword ngxappname03ive fastcgi_send_timeout
syn keyword ngxappname03ive fastcgi_split_path_info
syn keyword ngxappname03ive fastcgi_store
syn keyword ngxappname03ive fastcgi_store_access
syn keyword ngxappname03ive fastcgi_temp_file_write_size
syn keyword ngxappname03ive fastcgi_temp_path
syn keyword ngxappname03ive fastcgi_upstream_fail_timeout
syn keyword ngxappname03ive fastcgi_upstream_max_fails
syn keyword ngxappname03ive flv
syn keyword ngxappname03ive geoip_city
syn keyword ngxappname03ive geoip_country
syn keyword ngxappname03ive google_perftools_profiles
syn keyword ngxappname03ive gzip
syn keyword ngxappname03ive gzip_buffers
syn keyword ngxappname03ive gzip_comp_level
syn keyword ngxappname03ive gzip_disable
syn keyword ngxappname03ive gzip_hash
syn keyword ngxappname03ive gzip_http_version
syn keyword ngxappname03ive gzip_min_length
syn keyword ngxappname03ive gzip_no_buffer
syn keyword ngxappname03ive gzip_proxied
syn keyword ngxappname03ive gzip_static
syn keyword ngxappname03ive gzip_types
syn keyword ngxappname03ive gzip_vary
syn keyword ngxappname03ive gzip_window
syn keyword ngxappname03ive if_modified_since
syn keyword ngxappname03ive ignore_invalid_headers
syn keyword ngxappname03ive image_filter
syn keyword ngxappname03ive image_filter_buffer
syn keyword ngxappname03ive image_filter_jpeg_quality
syn keyword ngxappname03ive image_filter_transparency
syn keyword ngxappname03ive imap_auth
syn keyword ngxappname03ive imap_capabilities
syn keyword ngxappname03ive imap_client_buffer
syn keyword ngxappname03ive index
syn keyword ngxappname03ive ip_hash
syn keyword ngxappname03ive keepalive_requests
syn keyword ngxappname03ive keepalive_timeout
syn keyword ngxappname03ive kqueue_changes
syn keyword ngxappname03ive kqueue_events
syn keyword ngxappname03ive large_client_header_buffers
syn keyword ngxappname03ive limit_conn
syn keyword ngxappname03ive limit_conn_log_level
syn keyword ngxappname03ive limit_rate
syn keyword ngxappname03ive limit_rate_after
syn keyword ngxappname03ive limit_req
syn keyword ngxappname03ive limit_req_log_level
syn keyword ngxappname03ive limit_req_zone
syn keyword ngxappname03ive limit_zone
syn keyword ngxappname03ive lingering_time
syn keyword ngxappname03ive lingering_timeout
syn keyword ngxappname03ive lock_file
syn keyword ngxappname03ive log_format
syn keyword ngxappname03ive log_not_found
syn keyword ngxappname03ive log_subrequest
syn keyword ngxappname03ive map_hash_bucket_size
syn keyword ngxappname03ive map_hash_max_size
syn keyword ngxappname03ive master_process
syn keyword ngxappname03ive memcached_bind
syn keyword ngxappname03ive memcached_buffer_size
syn keyword ngxappname03ive memcached_connect_timeout
syn keyword ngxappname03ive memcached_next_upstream
syn keyword ngxappname03ive memcached_read_timeout
syn keyword ngxappname03ive memcached_send_timeout
syn keyword ngxappname03ive memcached_upstream_fail_timeout
syn keyword ngxappname03ive memcached_upstream_max_fails
syn keyword ngxappname03ive merge_slashes
syn keyword ngxappname03ive min_delete_depth
syn keyword ngxappname03ive modern_browser
syn keyword ngxappname03ive modern_browser_value
syn keyword ngxappname03ive msie_padding
syn keyword ngxappname03ive msie_refresh
syn keyword ngxappname03ive multi_accept
syn keyword ngxappname03ive open_file_cache
syn keyword ngxappname03ive open_file_cache_errors
syn keyword ngxappname03ive open_file_cache_events
syn keyword ngxappname03ive open_file_cache_min_uses
syn keyword ngxappname03ive open_file_cache_valid
syn keyword ngxappname03ive open_log_file_cache
syn keyword ngxappname03ive output_buffers
syn keyword ngxappname03ive override_charset
syn keyword ngxappname03ive perl
syn keyword ngxappname03ive perl_modules
syn keyword ngxappname03ive perl_require
syn keyword ngxappname03ive perl_set
syn keyword ngxappname03ive pid
syn keyword ngxappname03ive pop3_auth
syn keyword ngxappname03ive pop3_capabilities
syn keyword ngxappname03ive port_in_reappname03
syn keyword ngxappname03ive postpone_gzipping
syn keyword ngxappname03ive postpone_output
syn keyword ngxappname03ive protocol
syn keyword ngxappname03ive proxy
syn keyword ngxappname03ive proxy_bind
syn keyword ngxappname03ive proxy_buffer
syn keyword ngxappname03ive proxy_buffer_size
syn keyword ngxappname03ive proxy_buffering
syn keyword ngxappname03ive proxy_buffers
syn keyword ngxappname03ive proxy_busy_buffers_size
syn keyword ngxappname03ive proxy_cache
syn keyword ngxappname03ive proxy_cache_key
syn keyword ngxappname03ive proxy_cache_methods
syn keyword ngxappname03ive proxy_cache_min_uses
syn keyword ngxappname03ive proxy_cache_path
syn keyword ngxappname03ive proxy_cache_use_stale
syn keyword ngxappname03ive proxy_cache_valid
syn keyword ngxappname03ive proxy_connect_timeout
syn keyword ngxappname03ive proxy_headers_hash_bucket_size
syn keyword ngxappname03ive proxy_headers_hash_max_size
syn keyword ngxappname03ive proxy_hide_header
syn keyword ngxappname03ive proxy_ignore_client_abort
syn keyword ngxappname03ive proxy_ignore_headers
syn keyword ngxappname03ive proxy_intercept_errors
syn keyword ngxappname03ive proxy_max_temp_file_size
syn keyword ngxappname03ive proxy_method
syn keyword ngxappname03ive proxy_next_upstream
syn keyword ngxappname03ive proxy_pass_error_message
syn keyword ngxappname03ive proxy_pass_header
syn keyword ngxappname03ive proxy_pass_request_body
syn keyword ngxappname03ive proxy_pass_request_headers
syn keyword ngxappname03ive proxy_read_timeout
syn keyword ngxappname03ive proxy_reappname03
syn keyword ngxappname03ive proxy_send_lowat
syn keyword ngxappname03ive proxy_send_timeout
syn keyword ngxappname03ive proxy_set_body
syn keyword ngxappname03ive proxy_set_header
syn keyword ngxappname03ive proxy_ssl_session_reuse
syn keyword ngxappname03ive proxy_store
syn keyword ngxappname03ive proxy_store_access
syn keyword ngxappname03ive proxy_temp_file_write_size
syn keyword ngxappname03ive proxy_temp_path
syn keyword ngxappname03ive proxy_timeout
syn keyword ngxappname03ive proxy_upstream_fail_timeout
syn keyword ngxappname03ive proxy_upstream_max_fails
syn keyword ngxappname03ive random_index
syn keyword ngxappname03ive read_ahead
syn keyword ngxappname03ive real_ip_header
syn keyword ngxappname03ive recursive_error_pages
syn keyword ngxappname03ive request_pool_size
syn keyword ngxappname03ive reset_timedout_connection
syn keyword ngxappname03ive resolver
syn keyword ngxappname03ive resolver_timeout
syn keyword ngxappname03ive rewrite_log
syn keyword ngxappname03ive rtsig_overflow_events
syn keyword ngxappname03ive rtsig_overflow_test
syn keyword ngxappname03ive rtsig_overflow_threshold
syn keyword ngxappname03ive rtsig_signo
syn keyword ngxappname03ive satisfy
syn keyword ngxappname03ive secure_link_secret
syn keyword ngxappname03ive send_lowat
syn keyword ngxappname03ive send_timeout
syn keyword ngxappname03ive sendfile
syn keyword ngxappname03ive sendfile_max_chunk
syn keyword ngxappname03ive server_name_in_reappname03
syn keyword ngxappname03ive server_names_hash_bucket_size
syn keyword ngxappname03ive server_names_hash_max_size
syn keyword ngxappname03ive server_tokens
syn keyword ngxappname03ive set_real_ip_from
syn keyword ngxappname03ive smtp_auth
syn keyword ngxappname03ive smtp_capabilities
syn keyword ngxappname03ive smtp_client_buffer
syn keyword ngxappname03ive smtp_greeting_delay
syn keyword ngxappname03ive so_keepalive
syn keyword ngxappname03ive source_charset
syn keyword ngxappname03ive ssi
syn keyword ngxappname03ive ssi_ignore_recycled_buffers
syn keyword ngxappname03ive ssi_min_file_chunk
syn keyword ngxappname03ive ssi_silent_errors
syn keyword ngxappname03ive ssi_types
syn keyword ngxappname03ive ssi_value_length
syn keyword ngxappname03ive ssl
syn keyword ngxappname03ive ssl_certificate
syn keyword ngxappname03ive ssl_certificate_key
syn keyword ngxappname03ive ssl_ciphers
syn keyword ngxappname03ive ssl_client_certificate
syn keyword ngxappname03ive ssl_crl
syn keyword ngxappname03ive ssl_dhparam
syn keyword ngxappname03ive ssl_engine
syn keyword ngxappname03ive ssl_prefer_server_ciphers
syn keyword ngxappname03ive ssl_protocols
syn keyword ngxappname03ive ssl_session_cache
syn keyword ngxappname03ive ssl_session_timeout
syn keyword ngxappname03ive ssl_verify_client
syn keyword ngxappname03ive ssl_verify_depth
syn keyword ngxappname03ive starttls
syn keyword ngxappname03ive stub_status
syn keyword ngxappname03ive sub_filter
syn keyword ngxappname03ive sub_filter_once
syn keyword ngxappname03ive sub_filter_types
syn keyword ngxappname03ive tcp_nodelay
syn keyword ngxappname03ive tcp_nopush
syn keyword ngxappname03ive thread_stack_size
syn keyword ngxappname03ive timeout
syn keyword ngxappname03ive timer_resolution
syn keyword ngxappname03ive types_hash_bucket_size
syn keyword ngxappname03ive types_hash_max_size
syn keyword ngxappname03ive underscores_in_headers
syn keyword ngxappname03ive uninitialized_variable_warn
syn keyword ngxappname03ive use
syn keyword ngxappname03ive user
syn keyword ngxappname03ive userid
syn keyword ngxappname03ive userid_domain
syn keyword ngxappname03ive userid_expires
syn keyword ngxappname03ive userid_mark
syn keyword ngxappname03ive userid_name
syn keyword ngxappname03ive userid_p3p
syn keyword ngxappname03ive userid_path
syn keyword ngxappname03ive userid_service
syn keyword ngxappname03ive valid_referers
syn keyword ngxappname03ive variables_hash_bucket_size
syn keyword ngxappname03ive variables_hash_max_size
syn keyword ngxappname03ive worker_connections
syn keyword ngxappname03ive worker_cpu_affinity
syn keyword ngxappname03ive worker_priority
syn keyword ngxappname03ive worker_processes
syn keyword ngxappname03ive worker_rlimit_core
syn keyword ngxappname03ive worker_rlimit_nofile
syn keyword ngxappname03ive worker_rlimit_sigpending
syn keyword ngxappname03ive worker_threads
syn keyword ngxappname03ive working_appname03ory
syn keyword ngxappname03ive xclient
syn keyword ngxappname03ive xml_entities
syn keyword ngxappname03ive xslt_stylesheet
syn keyword ngxappname03ive xslt_types

" 3rd party module list:
" http://wiki.nginx.org/Nginx3rdPartyModules

" Accept Language Module <http://wiki.nginx.org/NginxAcceptLanguageModule>
" Parses the Accept-Language header and gives the most suitable locale from a list of supported locales.
syn keyword ngxappname03iveThirdParty set_from_accept_language

" Access Key Module <http://wiki.nginx.org/NginxHttpAccessKeyModule>
" Denies access unless the request URL contains an access key. 
syn keyword ngxappname03iveThirdParty accesskey
syn keyword ngxappname03iveThirdParty accesskey_arg
syn keyword ngxappname03iveThirdParty accesskey_hashmethod
syn keyword ngxappname03iveThirdParty accesskey_signature

" Auth PAM Module <http://web.iti.upv.es/~sto/nginx/>
" HTTP Basic Authentication using PAM.
syn keyword ngxappname03iveThirdParty auth_pam
syn keyword ngxappname03iveThirdParty auth_pam_service_name

" Cache Purge Module <http://labs.frickle.com/nginx_ngx_cache_purge/>
" Module adding ability to purge content from FastCGI and proxy caches.
syn keyword ngxappname03iveThirdParty fastcgi_cache_purge
syn keyword ngxappname03iveThirdParty proxy_cache_purge

" Chunkin Module <http://wiki.nginx.org/NginxHttpChunkinModule>
" HTTP 1.1 chunked-encoding request body support for Nginx.
syn keyword ngxappname03iveThirdParty chunkin
syn keyword ngxappname03iveThirdParty chunkin_keepalive
syn keyword ngxappname03iveThirdParty chunkin_max_chunks_per_buf
syn keyword ngxappname03iveThirdParty chunkin_resume

" Circle GIF Module <http://wiki.nginx.org/NginxHttpCircleGifModule>
" Generates simple circle images with the colors and size specified in the URL.
syn keyword ngxappname03iveThirdParty circle_gif
syn keyword ngxappname03iveThirdParty circle_gif_max_radius
syn keyword ngxappname03iveThirdParty circle_gif_min_radius
syn keyword ngxappname03iveThirdParty circle_gif_step_radius

" Drizzle Module <http://github.com/chaoslawful/drizzle-nginx-module>
" Make nginx talk appname03ly to mysql, drizzle, and sqlite3 by libdrizzle.
syn keyword ngxappname03iveThirdParty drizzle_connect_timeout
syn keyword ngxappname03iveThirdParty drizzle_dbname
syn keyword ngxappname03iveThirdParty drizzle_keepalive
syn keyword ngxappname03iveThirdParty drizzle_module_header
syn keyword ngxappname03iveThirdParty drizzle_pass
syn keyword ngxappname03iveThirdParty drizzle_query
syn keyword ngxappname03iveThirdParty drizzle_recv_cols_timeout
syn keyword ngxappname03iveThirdParty drizzle_recv_rows_timeout
syn keyword ngxappname03iveThirdParty drizzle_send_query_timeout
syn keyword ngxappname03iveThirdParty drizzle_server

" Echo Module <http://wiki.nginx.org/NginxHttpEchoModule>
" Brings 'echo', 'sleep', 'time', 'exec' and more shell-style goodies to Nginx config file.
syn keyword ngxappname03iveThirdParty echo
syn keyword ngxappname03iveThirdParty echo_after_body
syn keyword ngxappname03iveThirdParty echo_before_body
syn keyword ngxappname03iveThirdParty echo_blocking_sleep
syn keyword ngxappname03iveThirdParty echo_duplicate
syn keyword ngxappname03iveThirdParty echo_end
syn keyword ngxappname03iveThirdParty echo_exec
syn keyword ngxappname03iveThirdParty echo_flush
syn keyword ngxappname03iveThirdParty echo_foreach_split
syn keyword ngxappname03iveThirdParty echo_location
syn keyword ngxappname03iveThirdParty echo_location_async
syn keyword ngxappname03iveThirdParty echo_read_request_body
syn keyword ngxappname03iveThirdParty echo_request_body
syn keyword ngxappname03iveThirdParty echo_reset_timer
syn keyword ngxappname03iveThirdParty echo_sleep
syn keyword ngxappname03iveThirdParty echo_subrequest
syn keyword ngxappname03iveThirdParty echo_subrequest_async

" Events Module <http://docs.dutov.org/nginx_modules_events_en.html>
" Privides options for start/stop events.
syn keyword ngxappname03iveThirdParty on_start
syn keyword ngxappname03iveThirdParty on_stop

" EY Balancer Module <http://github.com/ry/nginx-ey-balancer>
" Adds a request queue to Nginx that allows the limiting of concurrent requests passed to the upstream.
syn keyword ngxappname03iveThirdParty max_connections
syn keyword ngxappname03iveThirdParty max_connections_max_queue_length
syn keyword ngxappname03iveThirdParty max_connections_queue_timeout

" Fancy Indexes Module <https://connectical.com/projects/ngx-fancyindex/wiki>
" Like the built-in autoindex module, but fancier.
syn keyword ngxappname03iveThirdParty fancyindex
syn keyword ngxappname03iveThirdParty fancyindex_exact_size
syn keyword ngxappname03iveThirdParty fancyindex_footer
syn keyword ngxappname03iveThirdParty fancyindex_header
syn keyword ngxappname03iveThirdParty fancyindex_localtime
syn keyword ngxappname03iveThirdParty fancyindex_readme
syn keyword ngxappname03iveThirdParty fancyindex_readme_mode

" GeoIP Module (DEPRECATED) <http://wiki.nginx.org/NginxHttp3rdPartyGeoIPModule>
" Country code lookups via the MaxMind GeoIP API.
syn keyword ngxappname03iveThirdParty geoip_country_file

" Headers More Module <http://wiki.nginx.org/NginxHttpHeadersMoreModule>
" Set and clear input and output headers...more than "add"!
syn keyword ngxappname03iveThirdParty more_clear_headers
syn keyword ngxappname03iveThirdParty more_clear_input_headers
syn keyword ngxappname03iveThirdParty more_set_headers
syn keyword ngxappname03iveThirdParty more_set_input_headers

" HTTP Push Module <http://pushmodule.slact.net/>
" Turn Nginx into an adept long-polling HTTP Push (Comet) server.
syn keyword ngxappname03iveThirdParty push_buffer_size
syn keyword ngxappname03iveThirdParty push_listener
syn keyword ngxappname03iveThirdParty push_message_timeout
syn keyword ngxappname03iveThirdParty push_queue_messages
syn keyword ngxappname03iveThirdParty push_sender

" HTTP Redis Module <http://people.FreeBSD.ORG/~osa/ngx_http_redis-0.3.1.tar.gz>>
" Redis <http://code.google.com/p/redis/> support.>
syn keyword ngxappname03iveThirdParty redis_bind
syn keyword ngxappname03iveThirdParty redis_buffer_size
syn keyword ngxappname03iveThirdParty redis_connect_timeout
syn keyword ngxappname03iveThirdParty redis_next_upstream
syn keyword ngxappname03iveThirdParty redis_pass
syn keyword ngxappname03iveThirdParty redis_read_timeout
syn keyword ngxappname03iveThirdParty redis_send_timeout

" HTTP JavaScript Module <http://wiki.github.com/kung-fu-tzu/ngx_http_js_module>
" Embedding SpiderMonkey. Nearly full port on Perl module.
syn keyword ngxappname03iveThirdParty js
syn keyword ngxappname03iveThirdParty js_filter
syn keyword ngxappname03iveThirdParty js_filter_types
syn keyword ngxappname03iveThirdParty js_load
syn keyword ngxappname03iveThirdParty js_maxmem
syn keyword ngxappname03iveThirdParty js_require
syn keyword ngxappname03iveThirdParty js_set
syn keyword ngxappname03iveThirdParty js_utf8

" Log Request Speed <http://wiki.nginx.org/NginxHttpLogRequestSpeed>
" Log the time it took to process each request.
syn keyword ngxappname03iveThirdParty log_request_speed_filter
syn keyword ngxappname03iveThirdParty log_request_speed_filter_timeout

" Memc Module <http://wiki.nginx.org/NginxHttpMemcModule>
" An extended version of the standard memcached module that supports set, add, delete, and many more memcached commands.
syn keyword ngxappname03iveThirdParty memc_buffer_size
syn keyword ngxappname03iveThirdParty memc_cmds_allowed
syn keyword ngxappname03iveThirdParty memc_connect_timeout
syn keyword ngxappname03iveThirdParty memc_flags_to_last_modified
syn keyword ngxappname03iveThirdParty memc_next_upstream
syn keyword ngxappname03iveThirdParty memc_pass
syn keyword ngxappname03iveThirdParty memc_read_timeout
syn keyword ngxappname03iveThirdParty memc_send_timeout
syn keyword ngxappname03iveThirdParty memc_upstream_fail_timeout
syn keyword ngxappname03iveThirdParty memc_upstream_max_fails

" Mogilefs Module <http://www.grid.net.ru/nginx/mogilefs.en.html>
" Implements a MogileFS client, provides a replace to the Perlbal reverse proxy of the original MogileFS.
syn keyword ngxappname03iveThirdParty mogilefs_connect_timeout
syn keyword ngxappname03iveThirdParty mogilefs_domain
syn keyword ngxappname03iveThirdParty mogilefs_methods
syn keyword ngxappname03iveThirdParty mogilefs_noverify
syn keyword ngxappname03iveThirdParty mogilefs_pass
syn keyword ngxappname03iveThirdParty mogilefs_read_timeout
syn keyword ngxappname03iveThirdParty mogilefs_send_timeout
syn keyword ngxappname03iveThirdParty mogilefs_tracker

" MP4 Streaming Lite Module <http://wiki.nginx.org/NginxMP4StreamingLite>
" Will seek to a certain time within H.264/MP4 files when provided with a 'start' parameter in the URL. 
syn keyword ngxappname03iveThirdParty mp4

" Nginx Notice Module <http://xph.us/software/nginx-notice/>
" Serve static file to POST requests.
syn keyword ngxappname03iveThirdParty notice
syn keyword ngxappname03iveThirdParty notice_type

" Phusion Passenger <http://www.modrails.com/documentation.html>
" Easy and robust deployment of Ruby on Rails application on Apache and Nginx webservers.
syn keyword ngxappname03iveThirdParty passenger_base_uri
syn keyword ngxappname03iveThirdParty passenger_default_user
syn keyword ngxappname03iveThirdParty passenger_enabled
syn keyword ngxappname03iveThirdParty passenger_log_level
syn keyword ngxappname03iveThirdParty passenger_max_instances_per_app
syn keyword ngxappname03iveThirdParty passenger_max_pool_size
syn keyword ngxappname03iveThirdParty passenger_pool_idle_time
syn keyword ngxappname03iveThirdParty passenger_root
syn keyword ngxappname03iveThirdParty passenger_ruby
syn keyword ngxappname03iveThirdParty passenger_use_global_queue
syn keyword ngxappname03iveThirdParty passenger_user_switching
syn keyword ngxappname03iveThirdParty rack_env
syn keyword ngxappname03iveThirdParty rails_app_spawner_idle_time
syn keyword ngxappname03iveThirdParty rails_env
syn keyword ngxappname03iveThirdParty rails_framework_spawner_idle_time
syn keyword ngxappname03iveThirdParty rails_spawn_method

" RDS JSON Module <http://github.com/agentzh/rds-json-nginx-module>
" Help ngx_drizzle and other DBD modules emit JSON data.
syn keyword ngxappname03iveThirdParty rds_json
syn keyword ngxappname03iveThirdParty rds_json_content_type
syn keyword ngxappname03iveThirdParty rds_json_format
syn keyword ngxappname03iveThirdParty rds_json_ret

" RRD Graph Module <http://wiki.nginx.org/NginxNgx_rrd_graph>
" This module provides an HTTP interface to RRDtool's graphing facilities.
syn keyword ngxappname03iveThirdParty rrd_graph
syn keyword ngxappname03iveThirdParty rrd_graph_root

" Secure Download <http://wiki.nginx.org/NginxHttpSecureDownload>
" Create expiring links.
syn keyword ngxappname03iveThirdParty secure_download
syn keyword ngxappname03iveThirdParty secure_download_fail_location
syn keyword ngxappname03iveThirdParty secure_download_path_mode
syn keyword ngxappname03iveThirdParty secure_download_secret

" SlowFS Cache Module <http://labs.frickle.com/nginx_ngx_slowfs_cache/>
" Module adding ability to cache static files.
syn keyword ngxappname03iveThirdParty slowfs_big_file_size
syn keyword ngxappname03iveThirdParty slowfs_cache
syn keyword ngxappname03iveThirdParty slowfs_cache_key
syn keyword ngxappname03iveThirdParty slowfs_cache_min_uses
syn keyword ngxappname03iveThirdParty slowfs_cache_path
syn keyword ngxappname03iveThirdParty slowfs_cache_purge
syn keyword ngxappname03iveThirdParty slowfs_cache_valid
syn keyword ngxappname03iveThirdParty slowfs_temp_path

" Strip Module <http://wiki.nginx.org/NginxHttpStripModule>
" Whitespace remover.
syn keyword ngxappname03iveThirdParty strip

" Substitutions Module <http://wiki.nginx.org/NginxHttpSubsModule>
" A filter module which can do both regular expression and fixed string substitutions on response bodies.
syn keyword ngxappname03iveThirdParty subs_filter
syn keyword ngxappname03iveThirdParty subs_filter_types

" Supervisord Module <http://labs.frickle.com/nginx_ngx_supervisord/>
" Module providing nginx with API to communicate with supervisord and manage (start/stop) backends on-demand.
syn keyword ngxappname03iveThirdParty supervisord
syn keyword ngxappname03iveThirdParty supervisord_inherit_backend_status
syn keyword ngxappname03iveThirdParty supervisord_name
syn keyword ngxappname03iveThirdParty supervisord_start
syn keyword ngxappname03iveThirdParty supervisord_stop

" Upload Module <http://www.grid.net.ru/nginx/upload.en.html>
" Parses multipart/form-data allowing arbitrary handling of uploaded files.
syn keyword ngxappname03iveThirdParty upload_aggregate_form_field
syn keyword ngxappname03iveThirdParty upload_buffer_size
syn keyword ngxappname03iveThirdParty upload_cleanup
syn keyword ngxappname03iveThirdParty upload_limit_rate
syn keyword ngxappname03iveThirdParty upload_max_file_size
syn keyword ngxappname03iveThirdParty upload_max_output_body_len
syn keyword ngxappname03iveThirdParty upload_max_part_header_len
syn keyword ngxappname03iveThirdParty upload_pass
syn keyword ngxappname03iveThirdParty upload_pass_args
syn keyword ngxappname03iveThirdParty upload_pass_form_field
syn keyword ngxappname03iveThirdParty upload_set_form_field
syn keyword ngxappname03iveThirdParty upload_store
syn keyword ngxappname03iveThirdParty upload_store_access

" Upload Progress Module <http://wiki.nginx.org/NginxHttpUploadProgressModule>
" Tracks and reports upload progress.
syn keyword ngxappname03iveThirdParty report_uploads
syn keyword ngxappname03iveThirdParty track_uploads
syn keyword ngxappname03iveThirdParty upload_progress
syn keyword ngxappname03iveThirdParty upload_progress_content_type
syn keyword ngxappname03iveThirdParty upload_progress_header
syn keyword ngxappname03iveThirdParty upload_progress_json_output
syn keyword ngxappname03iveThirdParty upload_progress_template

" Upstream Fair Balancer <http://wiki.nginx.org/NginxHttpUpstreamFairModule>
" Sends an incoming request to the least-busy backend server, rather than distributing requests round-robin.
syn keyword ngxappname03iveThirdParty fair
syn keyword ngxappname03iveThirdParty upstream_fair_shm_size

" Upstream Consistent Hash <http://wiki.nginx.org/NginxHttpUpstreamConsistentHash>
" Select backend based on Consistent hash ring.
syn keyword ngxappname03iveThirdParty consistent_hash

" Upstream Hash Module <http://wiki.nginx.org/NginxHttpUpstreamRequestHashModule>
" Provides simple upstream load distribution by hashing a configurable variable.
syn keyword ngxappname03iveThirdParty hash
syn keyword ngxappname03iveThirdParty hash_again

" XSS Module <http://github.com/agentzh/xss-nginx-module>
" Native support for cross-site scripting (XSS) in an nginx.
syn keyword ngxappname03iveThirdParty xss_callback_arg
syn keyword ngxappname03iveThirdParty xss_get
syn keyword ngxappname03iveThirdParty xss_input_types
syn keyword ngxappname03iveThirdParty xss_output_type

" uWSGI Module <http://wiki.nginx.org/HttpUwsgiModule>
" Allows Nginx to interact with uWSGI processes and control what parameters are passed to the process.
syn keyword ngxappname03iveThirdParty uwsgi_bind
syn keyword ngxappname03iveThirdParty uwsgi_buffer_size
syn keyword ngxappname03iveThirdParty uwsgi_buffering
syn keyword ngxappname03iveThirdParty uwsgi_buffers
syn keyword ngxappname03iveThirdParty uwsgi_busy_buffers_size
syn keyword ngxappname03iveThirdParty uwsgi_cache
syn keyword ngxappname03iveThirdParty uwsgi_cache_bypass
syn keyword ngxappname03iveThirdParty uwsgi_cache_key
syn keyword ngxappname03iveThirdParty uwsgi_cache_lock
syn keyword ngxappname03iveThirdParty uwsgi_cache_lock_timeout
syn keyword ngxappname03iveThirdParty uwsgi_cache_methods
syn keyword ngxappname03iveThirdParty uwsgi_cache_min_uses
syn keyword ngxappname03iveThirdParty uwsgi_cache_path
syn keyword ngxappname03iveThirdParty uwsgi_cache_use_stale
syn keyword ngxappname03iveThirdParty uwsgi_cache_valid
syn keyword ngxappname03iveThirdParty uwsgi_connect_timeout
syn keyword ngxappname03iveThirdParty uwsgi_hide_header
syn keyword ngxappname03iveThirdParty uwsgi_ignore_client_abort
syn keyword ngxappname03iveThirdParty uwsgi_ignore_headers
syn keyword ngxappname03iveThirdParty uwsgi_intercept_errors
syn keyword ngxappname03iveThirdParty uwsgi_max_temp_file_size
syn keyword ngxappname03iveThirdParty uwsgi_modifier1
syn keyword ngxappname03iveThirdParty uwsgi_modifier2
syn keyword ngxappname03iveThirdParty uwsgi_next_upstream
syn keyword ngxappname03iveThirdParty uwsgi_no_cache
syn keyword ngxappname03iveThirdParty uwsgi_param
syn keyword ngxappname03iveThirdParty uwsgi_pass
syn keyword ngxappname03iveThirdParty uwsgi_pass_header
syn keyword ngxappname03iveThirdParty uwsgi_pass_request_body
syn keyword ngxappname03iveThirdParty uwsgi_pass_request_headers
syn keyword ngxappname03iveThirdParty uwsgi_read_timeout
syn keyword ngxappname03iveThirdParty uwsgi_send_timeout
syn keyword ngxappname03iveThirdParty uwsgi_store
syn keyword ngxappname03iveThirdParty uwsgi_store_access
syn keyword ngxappname03iveThirdParty uwsgi_string
syn keyword ngxappname03iveThirdParty uwsgi_temp_file_write_size
syn keyword ngxappname03iveThirdParty uwsgi_temp_path

" highlight

hi link ngxComment Comment
hi link ngxVariable Identifier
hi link ngxVariableBlock Identifier
hi link ngxVariableString PreProc
hi link ngxBlock Normal
hi link ngxString String

hi link ngxBoolean Boolean
hi link ngxappname03iveBlock Statement
hi link ngxappname03iveImportant Type
hi link ngxappname03iveControl Keyword
hi link ngxappname03iveError Constant
hi link ngxappname03iveDeprecated Error
hi link ngxappname03ive Identifier
hi link ngxappname03iveThirdParty Special

let b:current_syntax = "nginx"
