# !/usr/local/bin/liquidsoap

#
# -- Server Definitions --
#

set("init.daemon",true)
set("init.daemon.pidfile.path","{{ liquidsoap.pid.path }}/{{ liquidsoap.pid.file }}")

# Some logging
set("log.file",true)
set("log.file.path","{{ liquidsoap.log.path }}/{{ liquidsoap.log.file }}")
set("log.level",5)
set("log.stdout", false)

# Telnet server
set("server.telnet",true)
#set("server.telnet.bind_addr","::1")
set("server.telnet.bind_addr","{{ liquidsoap.telnet.host }}")
set("server.telnet.port", {{ liquidsoap.telnet.port }})

# harbor
set("harbor.reverse_dns",false)

# decoder options, this reduces log spam
set("decoder.file_decoders",["META","MAD","OGG","FLAC","WAV","MIDI","AAC","MP4","CAMLIMAGES","SDL/IMAGE","GSTREAMER"])

#
# -- Custom Functions --
#

# Run this script when the live stream starts/stops
# some possible things, IRC update, send a tweet..
# gather track list at the end of a live set if it exists
# at the moment it just sets the title....
def live_start(headers)
    title = headers["ice-description"]
    artist = headers["ice-name"]

    log("Live-metadata title: " ^ title)
    log("Live-metadata artist: " ^ artist)

    ignore(server.execute("live.insert title=\"#{title}\", artist=\"#{artist}\", album=\"LIVE\""))
    system( "/home/beats/bin/notify.py --live --title \"#{title}\" --artist=\"#{artist}\" --channel={{ liquidsoap.station.name }} &" )
end

def live_stop()
    system( "/home/beats/bin/notify.py --dead --channel={{ liquidsoap.station.name }} &" )
end

# Log the outbound meta data
def call_notify( m )
    system( "/home/beats/bin/notify.py --channel={{ liquidsoap.station.name }} --album=\""^m["album"]^"\" --title=\""^m["title"]^"\" --artist=\""^m["artist"]^"\" &" )
end

# Harbor Authenticator
def live_auth(user,password) =
    ret = get_process_lines("/home/beats/bin/live_auth.py --logfile /home/beats/logs/live_auth.log {{ liquidsoap.station.name }} #{user} #{password}")
    ret = list.hd(ret)
    if (ret == "true") then
        true
    else
        false
    end
end

# crossfader
def crossfade(a,b)
  add(normalize=false,
      [ sequence([ blank(duration=1.0),
                   fade.initial(duration=2.5,b) ]),
        fade.final(duration=2.5,a) ])
end

#
# -- Audio Stream --
#

# i like this one too but if something happens to the sessions directory we're doomed anyway
failsafe = single("say:{{ liquidsoap.failsafe }}")

# This seems a more reliable way to get uniqueness; a fixed 12 hr timer tends to reload too frequently.
{% for location in liquidsoap.music.locations %}
{{ location.name }} = playlist(reload_mode="rounds", reload=1, "{{ location.path }}")
{% endfor %}

# randomize the playlists, with a slight focus on fresh content.
# this ratio will most certainly require tweaking!
jukebox = random(weights=[{% for location in liquidsoap.music.locations %}{{ location.weight }}{% endfor %}], [{% for location in liquidsoap.music.locations %}{{ location.name }},{% endfor %}])

# Requests queue, add to it via requests.push <url>
#requests = request.equeue(id="request")
requests = request.queue(id="request")

# seperate fallback for non-live sources
# since it is not track-sensitive, though live is
jukebox = fallback(
            track_sensitive=true,
            transitions = [ crossfade, crossfade ],
            [ requests, jukebox ])

# Harbor input for live DJs.
live = input.harbor(
            id = "live",
            on_connect = live_start,
            on_disconnect = live_stop,
            buffer=15.0,
            max=240.0,
            icy = true,
            port = 8888,
            auth = live_auth,
            "live")

# silence detection 
live = strip_blank(live, length=20., threshold=-50.)

# insert the icecast header meta data into the live audio stream
live = drop_metadata(live)
live = server.insert_metadata(id="live", live)

# Build the radio stream
radiostream = fallback(
	track_sensitive=false, # Do not wait for the currently playing track to finish
        transitions = [ crossfade, crossfade, crossfade ],
	[ live, jukebox, failsafe ]) # prefer live stream, otherwise depend upon the playlist 

# TODO ignore failures in the metadata update script 
radiostream = on_metadata( call_notify, radiostream )

#
# -- Outputs --
#

# save live streams to file
output.file({{ liquidsoap.recording.format }},
        fallible=true, perm=0o644,
        reopen_on_metadata=true,
        "{{ liquidsoap.recording.path }}/{{ liquidsoap.recording.pattern }}", live)

{% for mount in liquidsoap.icecast.mounts %}
output.icecast({{ mount.format }},mount="/{{ mount.mount }}",
	password = "{{ mount.password }}",
	url = "{{ liquidsoap.station.url }}", description = "{{ liquidsoap.station.description }}", radiostream )
{% endfor %}
