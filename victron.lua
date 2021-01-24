victron_protocol = Proto("victron", "Victron precision shunt")
local gatt = Dissector.get("btatt")
local btatt_value_f = Field.new("btatt.value")
local btatt_handle_f = Field.new("btatt.handle")
local btatt_opcode_f = Field.new("btatt.opcode")

fields = victron_protocol.fields 

fields.status   = ProtoField.uint8("victron.status", "Status", base.HEX)
fields.transaction_id = ProtoField.uint8 ("victron.transaction_id", "TransactionId", base.HEX)
fields.remaining   = ProtoField.uint8("victron.remaining", "Remainig pkts", base.DEC)
fields.protocol_type   = ProtoField.uint8("victron.protocol_type", "prot type", base.HEX)


local command_categories = {
	[0x03190308] = "history values",
	[0x03190309] = "history bools",
	[0x10190308] = "settings values",
	[0x10190309] = "settings bools",
	[0xed190308] = "values values",
	[0xed190309] = "values bools",
	[0x0f190308] = "mixed settings",
	[0xed190008] = "Orion Values",
	[0xee190008] = "Orion Settings",
	[0xec190008] = "streaming smartshunt",
	[0x05038119] = "streaming2",
	[0x19819395] = "streaming3",
	[0x02190008] = "Orion state",
}
fields.command_category = ProtoField.uint32("victron.cmd_category", "command category", base.HEX, command_categories)
fields.start_sequence   = ProtoField.uint32("victron.start_sequence", "start_squence", base.HEX)
fields.unknown_command  = ProtoField.uint8("victron.command", "unknown command", base.HEX)

local data_types = {
	[0x08] = "value (has length)",
	[0x09] = "bool (1byte fixed len)",
}
fields.data_type   = ProtoField.uint8("victron.data_type", "data type", base.HEX, data_types)


local value_types = {
	[0x8c] = "SmartShunt Current",
	[0x8d] = "Victron Voltage",
	[0x8e] = "SmartShunt Power",
	[0x7d] = "SmartShunt Starter",
	[0x8f] = "SmartSolar Battery Current",
	[0xbd] = "SmartSolar Solar Current",
	[0xbc] = "SmartSolar Power",
	[0xbb] = "SmartSolar Solar Voltage",
	[0xef] = "SmartSolar Setting Battery Voltage",
	[0xf0] = "SmartSolar Setting Charge Current",
	[0xf6] = "SmartSolar Setting Float Voltage",

}
fields.value   = ProtoField.uint8("victron.command", "command", base.HEX, value_types)
fields.current   = ProtoField.float("victron.current", value_types[0x8c], {" A"},  base.UNIT_STRING)
fields.voltage   = ProtoField.float("victron.voltage", value_types[0x8d], {" V"},  base.UNIT_STRING)
fields.power   = ProtoField.float("victron.power", value_types[0x8e], {" w"}, base.UNIT_STRING)
fields.starter   = ProtoField.float("victron.starter", value_types[0x7d], {"V"}, base.UNIT_STRING)
fields.battery_current   = ProtoField.float("victron.battery_current", value_types[0x8f], {"A"}, base.UNIT_STRING)
fields.solar_current   = ProtoField.float("victron.solar_current", value_types[0x8d], {"A"}, base.UNIT_STRING)
fields.solar_volt   = ProtoField.float("victron.solar_volt", value_types[0x8d], {"V"}, base.UNIT_STRING)
fields.solar_power   = ProtoField.float("victron.solarpower", value_types[0xbc], {" w"}, base.UNIT_STRING)
fields.float_voltage   = ProtoField.float("victron.float_voltage", value_types[0xf6], {" V"}, base.UNIT_STRING)
fields.set_battery_voltage   = ProtoField.uint16("victron.set_battery_voltage", value_types[0xef], base.UNIT_STRING, {" V"})
fields.set_charge_current   = ProtoField.uint16("victron.set_charge_current", value_types[0xf0], base.UNIT_STRING, {" A"})
local value_commands = {
	[0x8c] = {fields.current,1000},
	[0x8d] = {fields.voltage,100},
	[0x8e] = {fields.power,1}, --smartshunt
	[0x7d] = {fields.starter,100},
	[0x8f] = {fields.battery_current,10},
	[0xbc] = {fields.solar_power,100}, -- smartsolar
	[0xbd] = {fields.solar_current,10}, -- smartsolar
	[0xbb] = {fields.solar_volt,100}, -- smartsolar
	[0xef] = {fields.set_battery_voltage,1}, -- smartsolar setting
	[0xf0] = {fields.set_charge_current,1}, --smartsolar setting
	[0xf6] = {fields.float_voltage,100}, --smartsolar setting
}

local mixedsetting_types={
[0xff] = "Battery Charge Status", 
}
fields.mixedsettings   = ProtoField.uint8("victron.mixedsettings", "mixed settings", base.HEX, mixedsettings_types)
fields.state_of_charge = ProtoField.float("victron.state_of_charge", mixedsetting_types[0xff], {" %"}, base.DEC or base.UNIT_STRING)
fields.bool_bat_start_sync = ProtoField.bool("victron.bat_start_sync", "battery starts synchronized")
local mixedsetting_commands = {
	[0xfd] = {fields.bool_bat_start_sync,1},
	[0xff] = {fields.state_of_charge,100},
}

local orion_types = {
	[0xdb] = "Orion maybe not? charge mode",
	[0x8d] = "Orion Output Voltage",
	[0xbb] = "Orion Input Voltage",
	[0xe9] = "Orion Set Delayed start voltage delay",
	[0x09] = "Orion not?? charger state. 0x01 for both",
	[0xf7] = "Orion Absorption Voltage",
	[0xf6] = "Orion Float Voltage",
	[0xfc] = "Orion maybe?? bulk time limit as BCD HH:MM",
	[0x20] = "Orion maybe?? sec since? counts up ~1/sec", --not yet decoded, different category
}
fields.orion   = ProtoField.uint8("victron.orion", "orion command", base.HEX, orion_types)
fields.orion_in_volt = ProtoField.float("victron.orion_in_volt", orion_types[0xbb], {" V"}, base.DEC or base.UNIT_STRING)
fields.orion_out_volt = ProtoField.float("victron.orion_out_volt", orion_types[0x8d], {" V"}, base.DEC or base.UNIT_STRING)
fields.start_delay = ProtoField.float("victron.start_delay", orion_types[0xe9], {" sec"}, base.DEC or base.UNIT_STRING)
fields.orion_bool9 = ProtoField.bool("victron.orion_bool9", orion_types[0x09])
fields.orion_absorption = ProtoField.float("victron.orion_absorption", orion_types[0xf7], {" V"}, base.DEC or base.UNIT_STRING)
fields.orion_float = ProtoField.float("victron.orion_float", orion_types[0xf6], {" V"}, base.DEC or base.UNIT_STRING)
fields.orion_bulk_limit = ProtoField.float("victron.orion_bulk_limit", orion_types[0xfc], {"HH:MM"}, base.DEC or base.UNIT_STRING)
fields.orion_sec_since   = ProtoField.uint32("victron.orion_sec_since", orion_types[0x20], base.HEX)
local chargemode_strings = {
	[0x0b72] = "disabled. input volt., engine off",
	[0x0b7c] = "disabled. engine off",
	[0x0b68] = "disabled.",
	[0x0b5e] = "bulk loading",
}
fields.orion_charge_mode   = ProtoField.uint32("victron.orion_charge_mode", orion_types[0x07], base.HEX,chargemode_strings)

local orion_commands = {
	[0x8d] = {fields.orion_out_volt,100},
	[0xbb] = {fields.orion_in_volt,100},
	[0xe9] = {fields.start_delay,10},
	[0xf7] = {fields.orion_absorption,100},
	[0xf7] = {fields.orion_float,100},
	[0xfc] = {fields.orion_bulk_limit,1},
	[0x20] = {fields.orion_sec_since,1},
	[0xdb] = {fields.orion_charge_mode,1},
}
local orion_bool = {
	[0x09] = {fields.orion_bool9,1},
}

local orionsettings_types = {
	[0x36] = "Orion Shutdown Voltage",
	[0x37] = "Orion Start Voltage",
	[0x38] = "Orion Delayed Start Voltage",
	[0x39] = "Orion Start Delay",
}
fields.orion_settings   = ProtoField.uint8("victron.orion_settings", "orion settings", base.HEX, orionsettings_types)
fields.orion_shutdown_voltage = ProtoField.float("victron.orion_shutdown_voltage", orionsettings_types[0x36], {" V"}, base.DEC or base.UNIT_STRING)
fields.orion_start_voltage = ProtoField.float("victron.orion_start_voltage", orionsettings_types[0x37], {" V"}, base.DEC or base.UNIT_STRING)
fields.orion_delayed_voltage = ProtoField.float("victron.orion_delayed_voltage", orionsettings_types[0x38], {" V"}, base.DEC or base.UNIT_STRING)
local orionsettings_commands = {
	[0x36] = {fields.orion_shutdown_voltage, 100},
	[0x37] = {fields.orion_start_voltage, 100},
	[0x38] = {fields.orion_delayed_voltage, 100},
	[0x39] = {fields.start_delay, 1},
}

local hist_types = {
	[0x00] = "hist: deepest discharge",
	[0x01] = "hist: last discharge",
	[0x02] = "hist: Average Discharge",
	[0x03] = "hist: total charge cycles",
	[0x04] = "hist: full discharges",
	[0x05] = "hist: Cumulative Ah drawn",
	[0x06] = "hist: Min battery voltage",
	[0x07] = "hist: Max battery voltage",
	[0x08] = "hist: Time since last full",
	[0x09] = "hist: synchronizations",
	[0x10] = "hist: Discharged Energy",
	[0x11] = "hist: Charged Energy",
	[0x28] = "Alarms: Low SOC set",            -- alarms are disabled by setting to 0
	[0x29] = "Alarms: Low SOC clear",
	[0x20] = "Alarms: Low Voltage set",
	[0x21] = "Alarms: Low Voltage clear",
	[0x22] = "Alarms: High Voltage set",
	[0x23] = "Alarms: High Voltage clear",
	[0x24] = "Alarms: Low Starter Voltage set",
	[0x25] = "Alarms: Low Starter Voltage clear",
	[0x26] = "Alarms: High Starter Voltage set",
	[0x27] = "Alarms: High Starter Voltage clear",
}
fields.history = ProtoField.uint8("victron.history", "history", base.HEX, hist_types)
fields.hist_synch = ProtoField.uint16("victron.hist_synch", hist_types[0x09], base.DEC)
fields.hist_cycles = ProtoField.uint16("victron.cycles", hist_types[0x03], base.DEC)
fields.hist_deepest_discharge = ProtoField.float("victron.hist_deepest_discharge", hist_types[0x00], {" Ah"}, base.UNIT_STRING)
fields.hist_last_discharge = ProtoField.float("victron.hist_last_discharge", hist_types[0x01], {" Ah"}, base.UNIT_STRING)
fields.hist_avrg_discharge = ProtoField.float("victron.hist_avrg_discharge", hist_types[0x02], {" Ah"}, base.UNIT_STRING)
fields.hist_full_discharge = ProtoField.uint16("victron.hist_full_discharge", hist_types[0x04], base.DEC)
fields.hist_cum_drawn = ProtoField.float("victron.cum_drawn", hist_types[0x05], {" Ah"}, base.UNIT_STRING)
fields.hist_min_bat = ProtoField.float("victron.hist_min_bat", hist_types[0x06], {" V"}, base.UNIT_STRING)
fields.hist_max_bat = ProtoField.float("victron.hist_max_bat", hist_types[0x07], {" V"}, base.UNIT_STRING)
fields.hist_time_full = ProtoField.int32("victron.hist_time_full", hist_types[0x08])
fields.hist_discharged_energy = ProtoField.float("victron.hist_discharged_energy",  hist_types[0x10], {" kWh"}, base.UNIT_STRING)
fields.hist_charged_energy = ProtoField.float("victron.hist_charged_energy",  hist_types[0x11], {" kWh"}, base.UNIT_STRING)
fields.alarm_soc_set = ProtoField.uint16("victron.alarm_soc_set", hist_types[0x28], base.UNIT_STRING, {"%"})
fields.alarm_soc_clear = ProtoField.uint16("victron.alarm_soc_clear", hist_types[0x29], base.UNIT_STRING, {"%"})
fields.alarm_voltage_set = ProtoField.float("victron.alarm_voltage_set", hist_types[0x20], {"V"}, base.UNIT_STRING)
fields.alarm_voltage_clear = ProtoField.float("victron.alarm_voltage_clear", hist_types[0x21], {"V"}, base.UNIT_STRING)
fields.alarm_high_voltage_set = ProtoField.float("victron.alarm_high_voltage_set", hist_types[0x22], {"V"}, base.UNIT_STRING)
fields.alarm_high_voltage_clear = ProtoField.float("victron.alarm_high_voltage_clear", hist_types[0x23], {"V"}, base.UNIT_STRING)
fields.alarm_low_starter_set = ProtoField.float("victron.alarm_low_starter_set", hist_types[0x24], {"V"}, base.UNIT_STRING)
fields.alarm_low_starter_clear = ProtoField.float("victron.alarm_low_starter_clear", hist_types[0x25], {"V"}, base.UNIT_STRING)
fields.alarm_high_starter_set = ProtoField.float("victron.alarm_high_starter_set", hist_types[0x26], {"V"}, base.UNIT_STRING)
fields.alarm_high_starter_clear = ProtoField.float("victron.alarm_high_starter_clear", hist_types[0x27], {"V"}, base.UNIT_STRING)
local hist_commands = {
	[0x00] = {fields.hist_deepest_discharge,10},
	[0x01] = {fields.hist_last_discharge,10},
	[0x02] = {fields.hist_avrg_discharge,10},
	[0x03] = {fields.hist_cycles,1},
	[0x04] = {fields.hist_full_discharge,1},
	[0x05] = {fields.hist_cum_drawn,10},
	[0x06] = {fields.hist_min_bat,100},
	[0x07] = {fields.hist_max_bat,100},
	[0x08] = {fields.hist_time_full,1},
	[0x09] = {fields.hist_synch,1},
	[0x10] = {fields.hist_discharged_energy,100},
	[0x11] = {fields.hist_charged_energy,100},
	[0x28] = {fields.alarm_soc_set, 10},
	[0x29] = {fields.alarm_soc_clear, 10},
	[0x20] = {fields.alarm_voltage_set, 100},
	[0x21] = {fields.alarm_voltage_clear, 100},
	[0x22] = {fields.alarm_high_voltage_set, 100},
	[0x23] = {fields.alarm_high_voltage_clear, 100},
	[0x24] = {fields.alarm_low_starter_set, 100},
	[0x25] = {fields.alarm_low_starter_clear, 100},
	[0x26] = {fields.alarm_high_starter_set, 100},
	[0x27] = {fields.alarm_high_starter_clear, 100},
 }


command_class_type = { [0x0] = "status reply?", [0x4] ="data reply?", [0x8] = "bulk values??"}
fields.command_class   = ProtoField.uint8("victron.command_class", "command class", base.HEX, command_class_type)

data_size_type = { [0x08] = "8byte", [0x04] = "4ybte" , [0x02]="2byte", [0x01] = "1byte"}
fields.data_size   = ProtoField.uint8("victron.data_size", "data size", base.DEC)

fields.payload   = ProtoField.bytes("victron.payload", "payload", base.SPACE)
fields.data   = ProtoField.bytes("victron.data", "data", base.SPACE)
fields.arguments   = ProtoField.bytes("victron.arguments", "arguments", base.SPACE)
fields.crc   = ProtoField.uint8("victron.crc", "crc", base.HEX)
fields.reserved   = ProtoField.uint8("victron.reserved", "Reserved", base.HEX)



--fields.capacity   = ProtoField.float("victron.capacity", "capacity (%)", base.UNIT_STRING, { [0]="%"})
fields.capacity   = ProtoField.int32("victron.capacity", "capacity (Ah)")


local settings_types = {
	[0x00] = "set capacity!",
	[0x01] = "set charged voltage!",
	[0x02] = "set tail current!",
	[0x03] = "set charged detection time!",
	[0x04] = "set charge eff. factor!",
	[0x05] = "set peukert coefficient!",
	[0x06] = "set current threshold",
	[0x07] = "set time-to-go avg. per.",
	[0x08] = "set discharge floor!",
}
fields.settings_value   = ProtoField.uint8("victron.settings", "settings", base.HEX, settings_types)
fields.set_capacity   = ProtoField.int32("victron.set_capacity", settings_types[0x00])
fields.set_charged_volt  = ProtoField.float("victron.charged_voltage", settings_types[0x01], {" V"})
fields.set_dis_floor  = ProtoField.uint16("victron.dis_floor", settings_types[0x08], base.UNIT_STRING, {" %"})
fields.set_tail_current  = ProtoField.float("victron.set_tail_current", settings_types[0x02], {" %"})
fields.set_peukert  = ProtoField.float("victron.set_peukert", settings_types[0x05], {"%"})
fields.set_curr_threshold= ProtoField.float("victron.set_curr_threshold", settings_types[0x06], {[1]=" A"})
fields.set_charged_time= ProtoField.uint16("victron.set_charged_time", settings_types[0x03], base.UNIT_STRING,{" min"})
fields.set_eff_factor  = ProtoField.uint16("victron.set_eff_factor", settings_types[0x04],base.UNIT_STRING or base.DEC ,{" %"})
fields.set_timetogo  = ProtoField.uint16("victron.timetogo", settings_types[0x07], base.UNIT_STRING,{" min"})
fields.set_booltype  = ProtoField.uint8("victron.set_booltype", "bool type", base.HEX)
fields.set_boolvalue  = ProtoField.bool("victron.set_boolvalue", "bool value")
local settings_commands = {
	[0x00] = {fields.set_capacity, 1},
	[0x01] = {fields.set_charged_volt,10},
	[0x02] = {fields.set_tail_current,10},
	[0x03] = {fields.set_charged_time,1},
	[0x04] = {fields.set_eff_factor,1},
	[0x05] = {fields.set_peukert,100},
	[0x06] = {fields.set_curr_threshold,100},
	[0x07] = {fields.set_timetogo,1},
	[0x08] = {fields.set_dis_floor,10},	
}

fields.unknown8   = ProtoField.uint8("victron.unknown8", "Unknown8 value", base.HEX_HEX)
fields.unknown16   = ProtoField.uint16("victron.unknown16", "Unknown16 value", base.HEX_DEC)
fields.unknown24   = ProtoField.uint24("victron.unknown24", "Unknown24 value", base.HEX_DEC)
fields.unknown32   = ProtoField.uint32("victron.unknown32", "Unknown32 value", base.HEX_DEC)
fields.unknown_bool_type  = ProtoField.uint8("victron.unknown_bool_type", "unknwon bool type", base.HEX)
fields.unknown_bool_value  = ProtoField.bool("victron.unknown_bool_value", "unknown bool value")

local statuses = {
[0x00] = "New Command",
[0x01] = "Command Busy",
[0x02] = "Command Successful",
[0x03] = "Command Failure",
[0x04] = "Command No Response / Command Timeout",
[0x05] = "Command Not Support",
[0x82] = "Status Result",
}

function payload_dissector(buffer, pinfo, tree, size, command)
	fun = (command_dissector[command] and command_dissector[command]) or default_command
	fun(buffer,pinfo,tree,size,command)
end

fields.device_id   = ProtoField.uint64("victron.device_id", "device_id?", base.HEX)
local packet_types = {[0x0027] = "Bulk Values", [0x0024] = "Single Value", [0x001e] = "Orion Single Value"}
fields.packet_type = ProtoField.uint16("victron.packet_type", "packet type", base.HEX, packet_types)
local direction = { [0x52] = "send", [0x1b] = "recv", [0x001b] = "recv"}
fields.command_dir   = ProtoField.uint8("victron.command_dir", "direction", base.HEX, direction, 0xff)


function length_one(buffer, pinfo, subtree)
		
	-- pinfo.cols.info = name
	subtree:add_le(fields.reserved, buffer(0,1))

end

function add_unknown_bool(buffer,pinfo,subtree)

	subtree:add_le(fields.unknown_bool_type, buffer(0,1))
	subtree:add_le(fields.unknown_bool_value, buffer(1,1))
	return 2
end

function add_unknown_field(buffer,pinfo,subtree)
		-- unknwond filed depending on data size
	if data_size_nibble == 1 then
		unknown_field = fields.unknown8
	end

	if data_size_nibble == 2 then
		unknown_field = fields.unknown16
	end
	if data_size_nibble == 3 then
		unknown_field = fields.unknown24
	end
	if data_size_nibble == 4 then
		unknown_field = fields.unknown32
	end
		subtree:add_le(fields.unknown_command, buffer(0,1))
		subtree:add_le(unknown_field, buffer(2,data_size_nibble))
		return data_size_nibble
end

local unknown_command = {fields.unknown32, 1}
local unknown_bool = {fields.set_boolvalue,1}

function settings_bool(buffer, pinfo, subtree, bool_types)
	command = buffer(0,1):le_uint() 
	local fun
	if bool_types[command] == nil then
		fun = unknown_bool
	else
	 fun = bool_types[command]
	end
	subtree:add_le(fields.set_booltype, buffer(0,1))
	subtree:add_le(fun[1], buffer(1,1))
	return 2
end

function command_category(buffer, pinfo, subtree, data_size, command_types)

	command = buffer(0,1):le_uint() 
	local fun
	if command_types[command] == nil then
		fun = unknown_command
	else
	 fun = command_types[command]
	end
	local value = buffer(2,data_size):le_int() / fun[2] 
	subtree:add_le(fun[1], buffer(2,data_size), value)
	return data_size
end

local category_funs = {
[0x01190009] = {orion_commands,fields.orion},
[0x10190308] = {settings_commands,fields.settings_value},
[0xed190308] = {value_commands,fields.value},
[0x03190308] = {hist_commands, fields.history},
[0x0f190308] = {mixedsetting_commands, fields.mixedsettings},
[0xed190008] = {orion_commands, fields.orion},
[0xee190008] = {orionsettings_commands, fields.orion_settings},
[0x05038119] = {value_commands,fields.value},
[0x19810305] = {value_commands,fields.value},
[0x02190008] = {orion_commands, fields.orion},
}

local bool_Categories = {
	[0x10190309] = {orion_bool,fields.orion},
	[0x01190009] = {orion_bool,fields.orion},
}

function single_value(buffer,pinfo,subtree)	
	if buffer:len() <6 then
		return 0
	end
	subtree:add_le(fields.start_sequence, buffer(0,4))
	local data_type = buffer(0,1):le_uint()
	subtree:add_le(fields.data_type, buffer(0,1), data_type)

	local category = buffer(0,4):le_uint()
	subtree:add_le(fields.command_category, buffer(0,4))

	command_class_nibble = bit.rshift( bit.band(buffer(5,1):uint() , 0xf0) ,4)
	subtree:add_le(fields.command_class, buffer(5,1), command_class_nibble)
	data_size_nibble = bit.band(buffer(5,1):uint() , 0x0f)
	subtree:add_le(fields.data_size , buffer(5,1), data_size_nibble)
	local consumed = 6

	local header = buffer(0,4):le_uint()
	
	category_fun = category_funs[header]

	if category_fun  then
		subtree:add_le(category_fun[2], buffer(4,1))
		return consumed + command_category(buffer(4), pinfo, subtree, data_size_nibble, category_fun[1])
	end

	bool_fun = bool_Categories[header]
	if bool_fun then
		subtree:add_le(bool_fun[2], buffer(4,1))
		return consumed + settings_bool(buffer(4), pinfo, subtree, bool_fun[1])
	end		

	if  data_type== 0x09 then
		return add_unknown_bool(buffer(4),pinfo,subtree)
	else
		return add_unknown_field(buffer(4),pinfo,subtree)
	end
end



function bulkvalues(buffer,pinfo,tree)	
	print("victron: bulk")
	if buffer:len() < 4 then
		print("victron: bulk header too short")
		pinfo.desegment_offset = 0
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0
	end

	local packet_type = buffer(1,2):le_uint()
	local data_start =  buffer(3)
	tvbs = {}


	if command_categories[buffer(0,4):le_uint()] == nil then
		print("victron: header unknwon, need more bytes:") --eigentlich unfug. category ist unbekannt
		pinfo.desegment_offset = 0
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0
	end

	-- get the length of the packet buffer (Tvb).
	local pktlen = buffer:len()
	local bytes_consumed = 0
	

	while bytes_consumed < pktlen do
		local subtree = tree:add(victron_protocol, "Bulk Value", buffer)
		local result = single_value(buffer(bytes_consumed), pinfo, subtree)
		if result == 0 then
			print("victron: bulk need more bytes")
			pinfo.desegment_offset = bytes_consumed -- +3 new wireshark code subtracts ahndle itself
			pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		
			return bytes_consumed
		end
		bytes_consumed = bytes_consumed + result
	end

	if buffer(pktlen-2,2):le_uint() == 0xffff then
		print("final paekt found")
		pinfo.desegment_offset = pktlen -- +3 new wireshark code subtracts ahndle itself
		pinfo.desegment_len = 0
	end
	return bytes_consumed
end


function sending(buffer, pinfo, subtree)
	local send_commands = {
		[0xf941] = "Ping",
		[0xf980] = "0xf980",
	}	
	--subtree:add(fields.data, buffer(0))--:append_text(" ("..send_commands[buffer(3,2):uint()]..")")
	
end

function victron_protocol.dissector(buffer, pinfo, tree)
	--leftover when this dissector was attached to btl2cap.cid
	--gatt:call(buffer, pinfo, tree)
	--local opcode = btatt_opcode_f().value
	--local btatt_value = btatt_value_f()
	local packet_type = btatt_handle_f().value
	
	pinfo.cols.protocol = victron_protocol.name

	-- first 3 byte are handled by btatt dissector
	-- subtree:add_le(fields.command_dir, buffer(0,1)):append_text("send CMD")
	-- subtree:add_le(fields.characteristic, buffer(1,2))
	
	local subtree = tree:add(victron_protocol, buffer)
	subtree:add_le(fields.packet_type, packet_type):set_generated()
	
	if opcode == 0x52 then
		sending(buffer, pinfo, subtree)
		return
	end
	local bytes_consumed = 0
	if packet_type == 0x0027 then
		bytes_consumed = bulkvalues(buffer,pinfo,subtree)
	else	
		bytes_consumed = single_value(buffer,pinfo,subtree)
	end
	return bytes_consumed 
end


-- alternate property to attach to
-- DissectorTable.get("btl2cap.cid"):add(0x0004, victron_protocol)

-- DissectorTable.get("btatt.handle"):add(0x0004, victron_protocol)
-- DissectorTable.get("btatt.handle"):add(0x0020, victron_protocol)
-- DissectorTable.get("btatt.handle"):add(0x0023, victron_protocol)
-- DissectorTable.get("btatt.handle"):add(0x0026, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x0025, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x001b, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x000c, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x001e, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x0021, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x0027, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x0024, victron_protocol)
DissectorTable.get("btatt.handle"):add(0x0021, victron_protocol)