VictronConnect Bluetooth Protocol 
==============================

This repo is dedicated to the bluetooth protocol used by the VictronConnect app and devices of Victron Energy.
Currently there is some support for the following 3 devices:
  * SmartShunt battery monitor
  * Orion DC-DC Converters 
  * SmartSolar MPPT 150/35 

The protocol is partially understood, the repo contains 
  * a wireshark dissector 
  * properties per device 
  * protocol decoder in `victron.py`

All scripts are alpha quality, expert knowledge is needed. Documentation might be misleading / outdated!

**running this script can potentially destroy your device or battery/solar panel setup**

**You have been warned!**


Wireshark protocol dissector
----------------------------
copy or symlink `victron.lua` into the wireshark user plugin folder, see `https://www.wireshark.org/docs/wsug_html_chunked/ChPluginFolders.html`

make sure `btatt` protocol is enabled

filter for e.g. victron

single messages (on btatt.handle 0x0024 and others) from device to host are decoded. btatt.handle 0x0027 is a kind of streaming format where multiple messages are concatenated and split over many btatt messages. These cannot be reassembled at the moment, neither the BT l2cap disscetor nor the BT ATT dissector seem to implement packet reassembly.

Properties per device
---------------------------
the files `victron_...` contain device specific sequences to trigger value update messages as well as UUID mappings to receive the messages from the host bluetooth stack

protocol decoder in `victron.py`
---------------------------
The protocol decoder ~~is a mess~~ registers BT mac addresses in its main function

The VictronConnect protocol
---------------------------
Messages from device to host are partially understood, messages from host to devuce have not be included. The sequences to trigger vallue update messages have been observed while using the VictronConnect app.

The protocol uses very few BT attribute handles, most values are transportet in separate messages using btatt.handle 0x0024. 
A streaming format spanning BT packets is used on btatt.handle 0x0027 and others, this should be reassembled by the python decoder, padding at end of squence consisting of varying 0xFF is not implemented atm.
