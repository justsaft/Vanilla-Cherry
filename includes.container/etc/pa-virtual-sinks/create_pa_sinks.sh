#!/bin/bash

pactl load-module module-null-sink sink_name=micfx sink_properties="device.description='Mic FX'"
pactl load-module module-null-sink sink_name=game sink_properties="device.description='Game'"
pactl load-module module-null-sink sink_name=browser sink_properties="device.description='Browser'"
pactl load-module module-null-sink sink_name=music sink_properties="device.description='Music'"
pactl load-module module-null-sink sink_name=sfx sink_properties="device.description='SFX'"
pactl load-module module-null-sink sink_name=voicechat sink_properties="device.description='Voice Chat'"
pactl load-module module-null-sink sink_name=system sink_properties="device.description='System'"
pactl load-module module-null-sink sink_name=aux1 sink_properties="device.description='Aux 1'"
pactl load-module module-null-sink sink_name=aux2 sink_properties="device.description='Aux 2'"
pactl load-module module-null-sink sink_name=aux3 sink_properties="device.description='Aux 3'"