#!/bin/bash

pactl load-module module-null-sink sink_name=aux5 sink_properties="device.description='Aux 5'"
pactl load-module module-null-sink sink_name=aux6 sink_properties="device.description='Aux 6'"
pactl load-module module-null-sink sink_name=aux7 sink_properties="device.description='Aux 7'"
pactl load-module module-null-sink sink_name=aux8 sink_properties="device.description='Aux 8'"
pactl load-module module-null-sink sink_name=sfx sink_properties="device.description='SFX'"
pactl load-module module-null-sink sink_name=browser2 sink_properties="device.description='Secondary Browser'"
pactl load-module module-null-sink sink_name=streammusic sink_properties="device.description='Stream Music'"
pactl load-module module-null-sink sink_name=streammonitor sink_properties="device.description='Stream Monitor'"
pactl load-module module-null-sink sink_name=guestmaster sink_properties="device.description='Guest Master'"


#pw-cli create-object pipewire.null-audio-sink "node.name=MyNullSink" "media.class=Audio/Sink" "audio.position=[FL,FR]"