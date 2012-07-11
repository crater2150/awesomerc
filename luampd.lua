-------------------------------------------------------------------
-- Copyright (c) 2006 Stephen M. Jothen
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. The name of the author may not be used to endorse or promote products
--    derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
-- IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
-- NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------
-- LuaMPD - Lua interface to the MusicPD protocol
--
-- Author: Steve Jothen <sjothen at gmail dot com>
-------------------------------------------------------------------

------------------------------------------------
-- Classes and requires
------------------------------------------------

local socket = require("socket")
local luampd = {}

------------------------------------------------
-- Private functions and tables
------------------------------------------------

-- errors taken from ack.h in the mpd sources
local err_table = {
  ["1"] = "ACK_ERROR_NOT_LIST",
  ["2"] = "ACK_ERROR_ARG",
  ["3"] = "ACK_ERROR_PASSWORD",
  ["4"] = "ACK_ERROR_PERMISSION",
  ["5"] = "ACK_ERROR_UNKNOWN",

  ["50"] = "ACK_ERROR_NO_EXIST",
  ["51"] = "ACK_ERROR_PLAYLIST_MAX",
  ["52"] = "ACK_ERROR_SYSTEM",
  ["53"] = "ACK_ERROR_PLAYLIST_LOAD",
  ["54"] = "ACK_ERROR_UPDATE_ALREADY",
  ["55"] = "ACK_ERROR_PLAYER_SYNC",
  ["56"] = "ACK_ERROR_EXIST",
}

-- turns a table of strings into groups seperated by a
-- delimiting string, and then turns each group of lines
-- into key, value pair tables
local function multi_hash(delimiter, lines)
  local size = table.maxn(lines)
  local patches = {}
  local patch = {}

  while size >= 1 do

    if string.find(lines[size], delimiter) then
      -- add to the patches repository
      local k, v = socket.skip(2, string.find(lines[size], "(.+):%s(.+)"))

      if k and v then
        -- we have our key value pair!
        patch[string.lower(k)] = v
        -- we want the key to be lowercase
      end

      table.insert(patches, patch)
      patch = {}

    else
      -- were still modifying the current patch
      local k, v = socket.skip(2, string.find(lines[size], "(.+):%s(.+)"))

      if k and v then
        patch[string.lower(k)] = v
      end

    end

    size = size - 1

  end

  return patches
end

-- will turn a table of strings that match
-- key: value
-- into a table such as { key = value, key2 = value2 }
local function hash(lines)
  local hash = {}
  for key, value in pairs(lines) do
    local k, v = socket.skip(2, string.find(value, "(.+):%s(.+)"))
    if k and v then
      -- lowercase the key for easier access (tabl.artist rather than tabl.Artist)
      hash[string.lower(k)] = v
    end
  end
  return hash
end


local function handle_error(line)
  -- line is the actual error line received from mpd
  local err_num, com_num = socket.skip(2, string.find(line, "ACK %[(%d+)@(%d+)%]"))
  if err_table[err_num] then
    error(err_table[err_num])
  else
    -- unknown error
    error(err_table["5"])
  end
end

local function get_response(obj, command)

  -- collect the lines into this table
  local response_lines = {}

  if obj.socket then
    obj.socket:send(command .. '\n')
    -- send the command with newline and collect response
    -- a response is everything up until an ACK or OK
    local line = obj.socket:receive("*l")
    while (line ~= "OK") do
      if line == nil then
        -- bug?? on ubuntu mpd will close socket randomly
        -- with large playlists while listing them
        -- try playlistinfo (with playlist size > 13000)
        error("SOCKET_ERROR")
      elseif string.sub(line, 1, 3) == "ACK" then
        break
        -- let us handle this erro
      end
      table.insert(response_lines, line)
      line = obj.socket:receive("*l")
    end
    -- if we stopped on an ACK then we better return information about it..
    -- last line in the table will be the ack message
    if string.sub(line, 1, 3) == "ACK" then
      handle_error(line)
    --elseif line == "OK" then
    --  return true
    else
      return response_lines
    end
  else
    -- not connected??
    error("SOCKET_ERROR")
  end

end

------------------------------------------------
-- Public instance methods
------------------------------------------------

function luampd:new(info)

  -- local instance of object

  local instance = {
    hostname = info.hostname or "localhost",
    password = info.password or nil,
    port = info.port or 6600,
    debug = info.debug or false,
  }

  instance.socket = socket.connect(instance.hostname, instance.port)

  if instance.socket then
    -- try and get ok from the server
    local line = instance.socket:receive("*l")
    if line:find("OK MPD (.+)") then
      -- connected, send password
      if instance.password then
        instance.socket:send(string.format("password %s\n", self.password))
        -- correct password?
        local ok_pass = instance.socket:receive("*l")
        if ok_pass ~= "OK" then
          error(string.format("Wrong password to %s:d", instance.hostname, instance.port))
        end
      end
    else
      -- not mpd or wrong hostname
      error(string.format("Cant get response from %s:%d", instance.hostname, instance.port))
    end
  else
    -- socket.connect returns nil, somethings wrong
    error(string.format("Socket cant connect to %s:%d", instance.hostname, instance.port))
  end

  return setmetatable(instance, { __index = luampd })

end

------------------------------------------------
-- Admin functions
------------------------------------------------

-- Some of these functions are in the documentation but dont work?
-- disableoutput, enableoutput
function luampd:disableoutput(outputid)
  get_response(self, string.format("disableoutput %d", outputid))
end

function luampd:enableoutput(outputid)
  get_response(self, string.format("enableoutput %d", outputid))
end

function luampd:kill()
  get_response(self, "kill")
  self.socket = nil
end

function luampd:outputs()
  local response = get_response(self, "outputs")
  return hash(response)
end

function luampd:update()
  get_response(self, "update")
end

------------------------------------------------
-- Database functions
------------------------------------------------

function luampd:find(stype, swhat)
  local send_string = string.format("find %s \"%s\"", stype, swhat)
  local data = get_response(self, send_string)
  return multi_hash("^file:", data)
end

-- how should we handle these functions?
-- list/listall/lsinfo
function luampd:list(meta, meta2, search)
end

function luampd:listall(path)
end

function luampd:listallinfo(path)
  local send_string
  if path then
    send_string = string.format("listallinfo \"%s\"", path)
  else
    send_string = "listallinfo"
  end
  local response = get_response(self, send_string)
  local songs = multi_hash("file:(.+)", response)
  return songs
end

function luampd:lsinfo(path)
end

function luampd:search(stype, swhat)
  local send_string = string.format("search %s \"%s\"", stype, swhat)
  local data = get_response(self, send_string)
  return multi_hash("^file:", data)
end

------------------------------------------------
-- Playlist functions
------------------------------------------------

function luampd:add(file)
  local add = string.format("add \"%s\"", file)
  get_response(self, add)
end

function luampd:clear()
  get_response(self, "clear")
end

function luampd:currentsong()
  local song = get_response(self, "currentsong")
  local hash = hash(song)
  return hash
end

function luampd:delete(song)
  get_response(self, string.format("delete %d", song))
end

function luampd:deleteid(songid)
  get_response(self, string.format("deleteid %s", songid))
end

function luampd:load_playlist(path)
  get_response(self, string.format("load %s", path))
end

function luampd:move(from, to)
  get_response(self, string.format("move %d %d", from, to))
end

function luampd:moveid(fromid, toid)
  get_response(self, string.format("moveid %d %d", fromid, toid))
end

function luampd:playlistinfo(song)
  local send_string
  if song then
    send_string = string.format("playlistinfo %d", song)
    local response = get_response(self, send_string)
    return hash(response)
  else
    send_string = "playlistinfo"
    local response = get_response(self, send_string)
    return multi_hash("^file:", response)
  end
end

function luampd:playlistid(songid)
  local send_string
  if songid then
    send_string = string.format("playlistid %d", songid)
    local response = get_response(self, send_string)
    return hash(response)
  else
    send_string = "playlistid"
    local response = get_response(self, send_string)
    return multi_hash("^file:", response)
  end
end

function luampd:plchanges(version)
  local send_string = string.format("plchanges %d", version)
  local response = get_response(self, send_string)
  return multi_hash(response)
end

function luampd:plchangesposid(version)
end

function luampd:rm(name)
  get_response(self,
               string.format("rm \"%s\"", name))
end

function luampd:save(name)
  get_response(self,
               string.format("save \"%s\"", name))
end

function luampd:shuffle()
  get_response(self, "shuffle")
end

function luampd:swap(song1, song2)
  get_response(self,
               string.format("swap %d %d", song1, song2))
end

function luampd:swapid(songid1, songid2)
  get_response(self,
               string.format("swapid %d %d", songid1, songid2))
end

------------------------------------------------
-- Playback functions
------------------------------------------------

-- Some of the common tables:
--
-- Status:
--  Fields: volume, repeat, random, playlist, playlistlength, xfade,
--  state, song, songid, time, bitrate, audio
--
-- CurrentSong:
--  Fields: file, artist, album, track, title, time, pos, id

-- sets the crossfading to seconds and returns the xfade status
--
function luampd:crossfade(seconds)
  get_response(self,
               string.format("crossfade %d", seconds))
  return self:status()
end

-- go to next song, returns song table
--
function luampd:next_()
  get_response(self, "next")
  return self:currentsong()
end

-- pause the current song, returns true/false
-- (play, pause, stop, etc)
--
function luampd:pause()
  get_response(self, "pause")
  if self:status()["state"] == "pause" then
    return true
  else
    return false
  end
end

-- starts playing, returns the current song as a table
--
function luampd:play()
  get_response(self, "play")
  return self:currentsong()
end

-- start playing a song by its song id
--
function luampd:playid(songid)
  get_response(self,
               string.format("playid %d", songid))
  return self:currentsong()
end

-- go to the previous song and return the current song
--
function luampd:previous()
  get_response(self, "previous")
  return self:currentsong()
end

-- sets random on or off (state should be either
-- 1 (for on) or 0 (for off))
--
function luampd:random(state)
  get_response(self,
               string.format("random %d", state))
  if self:state()["random"] == tostring(state) then
    return true
  else
    return false
  end
end

-- sets repeat (see above about state)
--
function luampd:repeat_(state)
  get_response(self,
               string.format("repeat %d", state))
  if self:state()["repeat"] == tostring(state) then
    return true
  else
    return false
  end
end

-- seeks to the specified time (in seconds) in the song
-- returns status
function luampd:seek(song, time)
  get_response(self,
               string.format("seek %d %d", song, time))
  return self:status()
end

-- same as above, except uses songid instead of song
-- returns status
function luampd:seekid(songid, time)
  get_response(self,
               string.format("seekid %d %d", songid, time))
  return self:status()
end

-- set the volume (0-100), anything lower or higher should be handled
-- by the server (-10 will become 0, 110 will become 100)
-- returns status object
--
function luampd:setvol(vol)
  get_response(self,
               string.format("setvol %d", vol))
  if self:status()["volume"] == tostring(vol) then
    return true
  else
    return false
  end
end

-- stops playing and returns the current status object
function luampd:stop()
  get_response(self, "stop")
  if self:status()["state"] == "stop" then
    return true
  else
    return false
  end
end

------------------------------------------------
-- Miscellaneous functions
------------------------------------------------

function luampd:clearerror()
  get_response(self, "clearerror")
end

--
function luampd:close()
  get_response(self, "close")
  self.socket = nil
end

function luampd:commands()
end

function luampd:notcommands()
end

-- wrong password handled in get_response
function luampd:password(pass)
  get_response(self,
               string.format("password %s", pass))
end

function luampd:ping()
  get_response(self, "ping")
end

function luampd:stats()
  local stats = get_response(self, "stats")
  return hash(stats)
end

function luampd:status()
  local status = get_response(self, "status")
  return hash(status)
end

------------------------------------------------
-- More lua-esque functions, iterators
------------------------------------------------
-- 2011-03-15 crater2150: let iterators return size, which is already calculated
-- anyway

function luampd:database()
  local dbase = self:listallinfo(nil)
  local count = 0
  local size = table.maxn(dbase)
  return function()
    count = count + 1
    if count <= size then
      return dbase[count]
    end
  end, size
end

function luampd:playlist()
  local plist = self:playlistinfo(nil)
  local count = 0
  local size = table.maxn(plist)
  return function()
    count = count + 1
    if count <= size then
      return plist[count]
    end
  end, size
end

function luampd:ifind(stype, swhat)
  local found = self:find(stype, swhat)
  local count = 0
  local size = table.maxn(found)
  return function()
    count = count + 1
    if count <= size then
      return found[count]
    end
  end, size
end

function luampd:isearch(stype, swhat)
  local found = self:search(stype, swhat)
  local count = 0
  local size = table.maxn(found)
  return reverse_iterator(function()
    count = count + 1
    if count <= size then
      return found[count]
    end
  end, size), size
end

function reverse_iterator(iter, size)
	local reverse = {}
	i=0
	for elem in iter do
		reverse[size - i] = elem
		i = i+1
	end
	local count = 0
	return function()
		count = count + 1
		if count <= size then
			return reverse[count]
		end
	end
end

function luampd:iadd(file_iterator)
	for song in file_iterator do
		self:add(song.file)
	end
end

function luampd:idle()
  self.socket:send('idle\n')
end

function luampd:noidle()
  self.socket:send('noidle\n')
end

return luampd
