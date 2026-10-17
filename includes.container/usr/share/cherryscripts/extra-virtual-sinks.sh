#!/bin/bash
# Extra virtual sinks. They use the same format, rate and channel layout as
# the sinks in /etc/pipewire/pipewire.conf.d/10-sinks.conf.

create_sink() {
    local name="$1"
    local description="$2"
    pactl load-module module-null-sink \
        sink_name="$name" \
        format=float32le \
        rate=48000 \
        channels=2 \
        channel_map=front-left,front-right \
        sink_properties="device.description='$description' monitor.passthrough=true"
}

create_sink aux5          "Aux 5"
create_sink aux6          "Aux 6"
create_sink aux7          "Aux 7"
create_sink aux8          "Aux 8"
create_sink sfx           "SFX"
create_sink browser2      "Secondary Browser"
create_sink streammusic   "Stream Music"
create_sink streammonitor "Stream Monitor"
create_sink guestmaster   "Guest Master"
