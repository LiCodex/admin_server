local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local http = require "resty.http"
local mysql = require "mysql"
local mongo = require "resty.mongol"
local config = require "config"
require "functions"
local match = {}
match.data = {}
local arg=ngx.req.get_uri_args()
local uid=arg.uid
local gamename=arg.gamename
local projectname=arg.projectname

local cursor = config.get('gamelist',gamename)

if gamename == 'niuniu' then
	-- 牛牛自由match
	for i=1,3 do
		local cursor = config.get('gamelist',gamename,'index'..i)
		table.insert(match.data,cursor)
	end
elseif gamename == 'zhajinhua' then
	for i=7,9 do
		local cursor = config.get('gamelist',gamename,'index'..i)
		table.insert(match.data,cursor)
	end
elseif gamename == 'shaizi' then
	for i=10,12 do
		local cursor = config.get('gamelist',gamename,'index'..i)
		table.insert(match.data,cursor)
	end
end

table.dumpdebug(match,"============>>>>>>>ziyoumatch:::")
ngx.say(cjson.encode(match))
