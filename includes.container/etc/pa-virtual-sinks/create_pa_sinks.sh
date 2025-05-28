#!/bin/bash

pactl load-module module-null-sink sink-name=MicFX sink-properties=device.description="Mic FX"
pactl load-module module-null-sink sink-name=Game sink-properties=device.description="Game"
pactl load-module module-null-sink sink-name=Browser sink-properties=device.description="Browser"
pactl load-module module-null-sink sink-name=Music sink-properties=device.description="Music"
pactl load-module module-null-sink sink-name=SFX sink-properties=device.description="SFX"
pactl load-module module-null-sink sink-name=VoiceChats sink-properties=device.description="VoiceChats"
pactl load-module module-null-sink sink-name=System sink-properties=device.description="System"
pactl load-module module-null-sink sink-name=Aux1 sink-properties=device.description="Aux1"
pactl load-module module-null-sink sink-name=Aux2 sink-properties=device.description="Aux2"
pactl load-module module-null-sink sink-name=Aux3 sink-properties=device.description="Aux3"