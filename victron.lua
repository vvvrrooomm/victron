victron_protocol = Proto("victron", "VictronConnect protocol")
local gatt = Dissector.get("btatt")
local btatt_value_f = Field.new("btatt.value")
local btatt_handle_f = Field.new("btatt.handle")
local btatt_opcode_f = Field.new("btatt.opcode")

fields = victron_protocol.fields 

fields.unknown8   = ProtoField.uint8("victron.unknown8", "Unknown8 value", base.HEX_HEX)
fields.unknown16   = ProtoField.uint16("victron.unknown16", "Unknown16 value", base.HEX_DEC)
fields.unknown24   = ProtoField.uint24("victron.unknown24", "Unknown24 value", base.HEX_DEC)
fields.unknown32   = ProtoField.uint32("victron.unknown32", "Unknown32 value", base.HEX_DEC)
fields.unknown64   = ProtoField.uint64("victron.unknown64", "Unknown64 value", base.HEX_DEC)
fields.unknown_bytes   = ProtoField.bytes("victron.unknown_bytes", "Unknown bytes", base.SPACE)
fields.unknown_bool_type  = ProtoField.uint8("victron.unknown_bool_type", "unknown bool type", base.HEX)
fields.unknown_bool_value  = ProtoField.bool("victron.unknown_bool_value", "unknown bool value")


fields.status   = ProtoField.uint8("victron.status", "Status", base.HEX)
fields.transaction_id = ProtoField.uint8 ("victron.transaction_id", "TransactionId", base.HEX)
fields.remaining   = ProtoField.uint8("victron.remaining", "Remainig pkts", base.DEC)
fields.protocol_type   = ProtoField.uint8("victron.protocol_type", "prot type", base.HEX)
fields.leftover   = ProtoField.bytes("victron.leftover", "leftover bytes",base.SPACE, "used in the following packet")

-- linked to category_funs
local command_categories = {
	[0x01190308] = "base information",
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
fields.unknown_command  = ProtoField.uint8("victron.command", "unknown command", base.HEX)

local data_types = {
	[0x08] = "value (has length)",
	[0x09] = "bool (1byte fixed len)",
}
fields.data_type   = ProtoField.uint8("victron.data_type", "data type", base.HEX, data_types)

local prod_info = {
	[0x02] = "firmware version?",
	[0x0a] = "serial number",
	[0x0b] = "model name",
	[0x40] = "capabilities",
	[0x8d] = "",
	[0xbb] = "",
	[0xe2] = "",
	[0x09] = "",
	[0x0e] = "identification",
	[0xf7] = "",
	[0xf6] = "",
	[0xfc] = "",
	[0x10] = "UDF version?",
	[0x20] = "uptime?",
}
fields.base_commands = ProtoField.uint8("victron.base", "Product information", base.HEX, prod_info)
fields.base_serial = ProtoField.string("victron.base_serial","base serial")

local base_commands = {
	[0x0a] = {fields.base_serial,1,TvbRange.string},
}


local value_types = {
	[0x2e] = "Setting Re-bulk voltage offset",
	[0x7d] = "SmartShunt Starter",
	[0x8c] = "SmartShunt Current",
	[0x8d] = "Victron Voltage",
	[0x8e] = "SmartShunt Power",
	[0x8f] = "SmartSolar Battery Current",
	[0x91] = "SmartSolar Enable Streetlight",
	[0x96] = "SmartSolar sunset delay time",
	[0x97] = "SmartSolar sunrise delay time",
	[0x99] = "SmartSolar sunrise detection voltage",
	[0x9a] = "SmartSolar sunset detection voltage",
	[0x9b] = "SmartSolar Gradual Dimming speed",
	[0x9c] = "SmartSolar Setting Load Output off level",
	[0x9d] = "SmartSolar Setting Load Output on level",
	[0x9e] = "SmartSolar TX port mode",
	[0xa0] = "SmartSolar Setting Sunset Action",
	[0xa1] = "SmartSolar interval before sunset action",
	[0xa2] = "SmartSolar Setting Sunrise Action",
	[0xa3] = "SmartSolar interval before sunrise action",
	[0xa7] = "SmartSolar Mid Point Shift",
	[0xa8] = "SmartSolar Load output state",
	[0xa9] = "HomeSmartSolar Battery Voltage(??)",
	[0xab] = "SmartSolar Setting Load Output Mode",
	[0xac] = "SmartSolar Load output offset voltage?",
	[0xbb] = "SmartSolar Solar Voltage",
	[0xbc] = "SmartSolar Power",
	[0xbd] = "SmartSolar Solar Current",
	[0xca] = "Voltage compensation",
	[0xd4] = "Charger additional state information",
	[0xda] = "Charger error code",
	[0xda] = "Charger internal temperature",
	[0xdc] = "SmartSolar User Yield",
	[0xdd] = "SmartSolar System Yield",
	[0xdf] = "Charger maximum current",
	[0xe0] = "Setting Battery Temperature Cutoff",
	[0xe3] = "Setting Battery maximum equalisation duration",
	[0xe4] = "Setting Battery equalisation current",
	[0xe5] = "Setting Battery equalisation stop mode",
	[0xe6] = "Enable Battery Temperature Cutoff",
	[0xe7] = "Setting Battery Tail Current",
	[0xe8] = "Battery BMS present?",
	[0xea] = "Battery voltage setting",
	[0xef] = "Setting Battery voltage selection",
	[0xf0] = "Setting Battery maximum current",
	[0xf1] = "Setting Battery Type",
	[0xf2] = "Setting Battery temperature compensation setting",
	[0xf4] = "Setting Battery equalisation voltage level",
	[0xf6] = "Setting Battery float voltage level",
	[0xf7] = "Setting Battery absorption voltage level",
	[0xfb] = "Setting Battery absorption time limit",
	[0xfd] = "Setting Battery equalization frequency",
	[0xfe] = "Setting Battery adaptive mode",
}

fields.value   = ProtoField.uint8("victron.command", "command", base.HEX, value_types)
fields.current   = ProtoField.float("victron.current", value_types[0x8c], {" A"})
fields.voltage   = ProtoField.float("victron.voltage", value_types[0x8d], {" V"})
fields.power   = ProtoField.int16("victron.power", value_types[0x8e], base.UNIT_STRING, {" W"})
fields.starter   = ProtoField.float("victron.starter", value_types[0x7d], {"V"})
fields.battery_current   = ProtoField.float("victron.battery_current", value_types[0x8f], {"A"})
fields.battery_voltage   = ProtoField.float("victron.battery_voltage", value_types[0xa9], {" V"}) -- observed in HomseSmartSolar
fields.solar_current   = ProtoField.float("victron.solar_current", value_types[0xbd], {" A"})
fields.solar_volt   = ProtoField.float("victron.solar_volt", value_types[0xbb], {" V"})
fields.solar_power   = ProtoField.float("victron.solarpower", value_types[0xbc], {" W"})
fields.set_temp_comp   = ProtoField.float("victron.set_temp_comp", value_types[0xf2], {" mV/°C"})
fields.eq_voltage   = ProtoField.float("victron.eq_voltage", value_types[0xf4], {" V"})
fields.float_voltage   = ProtoField.float("victron.float_voltage", value_types[0xf6], {" V"})
fields.set_batt_abs_voltage   = ProtoField.float("victron.set_batt_abs_voltage", value_types[0xf7], {" V"})
fields.abs_time_limit   = ProtoField.int16("victron.abs_time_limit", value_types[0xfb], base.UNIT_STRING, {" h"})
fields.eq_freq   = ProtoField.int16("victron.eq_freq", value_types[0xfd], base.UNIT_STRING, {" d"})
fields.sunset_delay   = ProtoField.int16("victron.sunset_delay", value_types[0x96], base.UNIT_STRING, {" min"})
fields.sunrise_delay   = ProtoField.int16("victron.sunset_delay", value_types[0x97], base.UNIT_STRING, {" min"})
fields.sunrise_voltage   = ProtoField.float("victron.sunrise_voltage", value_types[0x99], {" V"})
fields.sunset_voltage   = ProtoField.float("victron.sunset_voltage", value_types[0x9a], {" V"})
fields.dimm_speed   = ProtoField.int16("victron.dimm_speed", value_types[0x9b], base.UNIT_STRING, {" s/%"})
fields.lo_low_voltage   = ProtoField.float("victron.lo_low_voltage", value_types[0x9c], {" V"})
fields.lo_high_voltage   = ProtoField.float("victron.lo_high_voltage", value_types[0x9d], {" V"})
fields.port_mode   = ProtoField.uint8("victron.port_mode", value_types[0x9e])
fields.mid_point_shift   = ProtoField.int16("victron.mid_point_shift", value_types[0xa7], base.UNIT_STRING, {" min"})
fields.lo_status   = ProtoField.bool("victron.lo_status", value_types[0xa8])
fields.internal_temp   = ProtoField.float("victron.internal_temp", value_types[0xdb], {" °C"})
fields.user_yield   = ProtoField.float("victron.user_yield", value_types[0xdc], {" kWh"})
fields.system_yield   = ProtoField.float("victron.user_yield", value_types[0xdd], {" kWh"})
fields.chg_max_current   = ProtoField.float("victron.chg_max_current", value_types[0xdf], {" A"})
fields.rebulk_offs   = ProtoField.float("victron.rebulk_offs", value_types[0x2e])
fields.temp_cutoff   = ProtoField.float("victron.temp_cutoff", value_types[0xe0])
fields.max_eq_dur   = ProtoField.float("victron.max_eq_dur", value_types[0xe3])
fields.eq_current   = ProtoField.uint16("victron.eq_current", value_types[0xe4], base.UNIT_STRING, {" %"})
fields.tail_current   = ProtoField.float("victron.tail_current", value_types[0xe7], {" A"})
fields.set_battery_voltage   = ProtoField.uint16("victron.set_battery_voltage", value_types[0xef], base.UNIT_STRING, {" V"})
fields.battery_voltage   = ProtoField.uint16("victron.battery_voltage", value_types[0xea], base.UNIT_STRING, {" V"})
fields.set_charge_current   = ProtoField.uint16("victron.set_charge_current", value_types[0xf0], base.UNIT_STRING, {" A"})
fields.volt_comp   = ProtoField.uint16("victron.volt_comp", value_types[0xca], base.UNIT_STRING, {" V"})

local value_commands = {
	[0x2e] = {fields.rebulk_offs,100},
	[0x7d] = {fields.starter,100},
	[0x8c] = {fields.current,1000},
	[0x8d] = {fields.voltage,100},
	[0x8e] = {fields.power,1}, --smartshunt
	[0x8f] = {fields.battery_current,10},
	[0x96] = {fields.sunset_delay,1}, --smartsolar setting
	[0x97] = {fields.sunrise_delay,1}, --smartsolar setting
	[0x99] = {fields.sunrise_voltage,100}, --smartsolar setting
	[0x9a] = {fields.sunset_voltage,100}, --smartsolar setting
	[0x9b] = {fields.dimm_speed,1}, --smartsolar setting
	[0x9c] = {fields.lo_low_voltage,100}, --smartsolar setting
	[0x9d] = {fields.lo_high_voltage,100}, --smartsolar setting
	[0xa7] = {fields.mid_point_shift,1},
	[0xa8] = {fields.lo_status,1}, --smartsolar setting
	[0xa9] = {fields.battery_voltage,100},
	[0xbb] = {fields.solar_volt,100}, -- smartsolar
	[0xbc] = {fields.solar_power,100}, -- smartsolar
	[0xbd] = {fields.solar_current,10}, -- smartsolar
	[0xca] = {fields.volt_comp,100},
	[0xdb] = {fields.internal_temp,100}, --smartsolar setting
	[0xdc] = {fields.user_yield,100}, --smartsolar setting
	[0xdd] = {fields.system_yield,100}, --smartsolar setting
	[0xdf] = {fields.chg_max_current,10}, --smartsolar setting
	[0xe0] = {fields.temp_cutoff,100},
	[0xe3] = {fields.max_eq_dur,100},
	[0xe4] = {fields.eq_current,1},
	[0xe7] = {fields.tail_current,10},
	[0xea] = {fields.battery_voltage,1},
	[0xef] = {fields.set_battery_voltage,1},
	[0xf0] = {fields.set_charge_current,10},
	[0xf2] = {fields.set_temp_comp,-100}, -- this value is supposed to be negative - how to do?
	[0xf4] = {fields.eq_voltage,100},
	[0xf6] = {fields.float_voltage,100},
	[0xf7] = {fields.set_batt_abs_voltage,100},
	[0xfb] = {fields.abs_time_limit,100},
	[0xfd] = {fields.eq_freq,1},
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

local streamingcommands_types= {
	[0x17] = "unknown, decode as array",
	[0x20] = "unknown",
	[0x30] = "unknwon",
	[0x31] = "unknown,decode as array",
}
fields.streaming_commands =  ProtoField.uint8("victron.streamingcommands", "streaming commands", base.HEX, streamingcommands_types)
local streaming_commands = {
	[0x17] = {fields.unknown_bytes,1,TvbRange.string},
	[0x20] = {fields.unknown_bytes,1},
	[0x30] = {fields.unknown8,1},
	[0x31] = {fields.unknown_bytes,1, TvbRange.string},
}

fields.smartshunt_bool = ProtoField.bool("victron.smartshunt_bool", "unknown bool")
local smartshunt_bool = {
	[0x41] = {fields.smartshunt_bool,1},
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

-- format is {field_prototype, divisor, converter function}
-- converter is a function of TvBRange, the class used as tvb variable
local orion_commands = {
	[0x8d] = {fields.orion_out_volt,100, TvbRange.int},
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


cbor_type = { [0x0] = "unsigned", [0x1] ="signed", [0x02]="unstructured string", [0x03]="UTF8 string", [0x04]="array", [0x05]="map", [0x06]="tag"}
fields.cbor_type   = ProtoField.uint8("victron.cbor_type", "CBOR Type", base.HEX, cbor_type)

data_size_type = { [0x08] = "8byte", [0x04] = "4ybte" , [0x02]="2byte", [0x01] = "1byte"}
fields.data_size   = ProtoField.uint8("victron.data_size", "data size", base.DEC)

fields.payload   = ProtoField.bytes("victron.payload", "payload", base.SPACE)
fields.data   = ProtoField.bytes("victron.data", "data", base.SPACE)
fields.arguments   = ProtoField.bytes("victron.arguments", "arguments", base.SPACE)
fields.crc   = ProtoField.uint8("victron.crc", "crc", base.HEX)
fields.reserved   = ProtoField.uint8("victron.reserved", "Reserved", base.HEX)
fields.padding   = ProtoField.bytes("victron.padding", "Padding")

page_group = {
	{0x00, 0x00, "VReg commands"}, 
	{0x01, 0x01, "Product information / Update"}, 
	{0x02, 0x7f, "Device Control"}, 
	{0x80, 0xee, "Product specific"}, 
	{0xf0,0xff,"Reserved"}
} -- https://www.victronenergy.de/upload/documents/VE.Can-registers-public.pdf
fields.page   = ProtoField.uint8("victron.page", "VREG Page", base.RANGE_STRING, page_group)


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
	[0x31] = "Streaming data",
	[0x50] = "History Details (2pkt)",
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

fields.array_total_work  = ProtoField.float("victron.array_total_work", "Total Work", {" kWh"})
fields.array_day_index  = ProtoField.float("victron.array_day_index", "Today minus", {" days"})
fields.array_bat_vmax  = ProtoField.float("victron.array_bat_vmax", "Bat Vmax", {" V"})
fields.array_bat_vmin  = ProtoField.float("victron.array_bat_vmin", "Bat Vmin", {" V"})
fields.array_solar_pmax  = ProtoField.float("victron.array_solar_pmax", "Solar PMax", {" W"})
fields.array_solar_vmax  = ProtoField.float("victron.array_solar_vmax", "Solar Vmax", {" V"})

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

function add_unknown_field(buffer,size, pinfo,subtree)
	local unknown_field = fields.unknown_bytes
		-- unknownd filed depending on data size
	if size == 1 then
		unknown_field = fields.unknown8
	end

	if size == 2 then
		unknown_field = fields.unknown16
	end
	if size == 3 then
		unknown_field = fields.unknown24
	end
	if size == 4 then
		unknown_field = fields.unknown32
	end
		subtree:add_le(fields.unknown_command, buffer(0,1))
		subtree:add_le(unknown_field, buffer(2,size))
		print("unknown field added, size:"..size)
		return size
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
	local converter = TvbRange.le_int
	if fun[3] then
		converter = fun[3]
	end

	local value
	if converter == TvbRange.string then
		value = converter(buffer(2,data_size))
	else
		-- equivalent: buffer(2,data_size):le_int()
		value = converter(buffer(2,data_size)) / fun[2] 
	end
	subtree:add_le(fun[1], buffer(2,data_size), value)
	return data_size
end


function history_category(buffer, pinfo, subtree, data_size, command_types)

	command = buffer(0,1):le_uint() 
	local fun
	if command_types[command] == nil then
		fun = unknown_command
	else
	 fun = command_types[command]
	end
	--for array type packets the data_size is the size of the field containing 
	-- the amount of total_bytes, including the total_bytes field
	local total_bytes = buffer(2,1):le_uint()
	print("array total_bytes:"..total_bytes.." len:"..buffer():len())
	if total_bytes+2 > buffer():len() then
		pinfo.desegment_offset = 0 -- random choice > 0 && < leftover size
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0
	end
	-- offset to package counter is -5
	subtree:add_le(fields.data_size, buffer(2,1))
	subtree:add_le(fields.array_bat_vmax, buffer(12,2), buffer(12,2):le_int()/100)
	subtree:add_le(fields.array_bat_vmin, buffer(14,2), buffer(14,2):le_int()/100)
	subtree:add_le(fields.array_total_work, buffer(21,2),buffer(21,2):le_uint()/100)
	subtree:add_le(fields.array_solar_pmax, buffer(27,1),buffer(27,1):le_uint()/1)
	subtree:add_le(fields.array_solar_vmax, buffer(33,2),buffer(33,2):le_uint()/100)
	subtree:add_le(fields.array_day_index, buffer(35,1),buffer(35,1):le_uint()/1-54)
	
	
	--subtree:add_le(fun[1], buffer(2,data_size))
	return total_bytes 
end

local category_funs = {
	[0x01190308] = {base_commands, fields.base_commands},
	[0x03190308] = {hist_commands, fields.history},
	[0x0f190308] = {mixedsetting_commands, fields.mixedsettings},
	[0x10190308] = {settings_commands,fields.settings_value},
	[0xed190308] = {value_commands,fields.value},
	[0x02190008] = {orion_commands, fields.orion},
	[0xec190008] = {streaming_commands, fields.streaming_commands},
	[0xed190008] = {orion_commands, fields.orion},
	[0xee190008] = {orionsettings_commands, fields.orion_settings},
	[0x01190009] = {orion_commands,fields.orion},
	[0x05038119] = {value_commands,fields.value},
	[0x19810305] = {value_commands,fields.value},
}

local bool_Categories = {
	[0x10190309] = {orion_bool,fields.orion},
	[0x01190009] = {orion_bool,fields.orion},
}

local function prepare_subtree(buffer, tree, packet_type)
	local subtree = tree:add(victron_protocol, buffer)
	subtree:add_le(fields.packet_type, packet_type):set_generated()
	return subtree
end

local MINIMUM_PACKET_SIZE = 7

function single_value(buffer,pinfo,subtree)	
	if buffer:len() < MINIMUM_PACKET_SIZE then
		print("victron: single value need more bytes (header)")
		pinfo.desegment_offset = -1
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0 -- not enough data to dissect
	end

	local consumed = 6 -- headers and minimal packet
	cbor_type_bits = bit.rshift( bit.band(buffer(5,1):uint() , 0xe0) ,5)

	data_size_bits = bit.band(buffer(5,1):uint() , 0x1f)
	if data_size_bits+6 > buffer:len() then
		print("victron: single value need more bytes (data)")
		pinfo.desegment_offset = 0
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0 -- not enough data to dissect
	end

	subtree:add_le(fields.command_category, buffer(0,4))
	local data_type = buffer(0,1):le_uint()
	subtree:add_le(fields.data_type, buffer(0,1), data_type)

	subtree:add_le(fields.page, buffer(3,1))

	local category = buffer(4,1):le_uint()
	local history_index = category - 0x50
	local category_text = nil
	if (history_index >= 0) and (history_index <= 31) then
		category = 0x50
		category_text = "today - "..history_index .."days"
	end
	--subtree:add_le(fields.command_category, buffer(4,1))
	local header = buffer(0,4):le_uint()
	
	category_fun = category_funs[header]

	if category_fun  then
		subtree:add_le(category_fun[2], buffer(4,1), category, nil, category_text)
		subtree:add_le(fields.cbor_type, buffer(5,1), cbor_type_bits)
		subtree:add_le(fields.data_size , buffer(5,1), data_size_bits)
		if ((history_index >= 0) and (history_index <= 31)) or category == 0x4f   then -- unknown end of history. we could imagine 0xff-0x50= 175 days of hsitory 
			pinfo.cols.info = "history"
			local result = history_category(buffer(4), pinfo, subtree, data_size_bits, category_fun[1])	
			-- needs to return 0 to trigger wireshark packet reassembly
			return (result > 0) and result+consumed or result
		else
			pinfo.cols.info = "command"
			return consumed + command_category(buffer(4), pinfo, subtree, data_size_bits, category_fun[1])
		end
	end

	bool_fun = bool_Categories[header]
	if bool_fun then
		subtree:add_le(bool_fun[2], buffer(4,1))
		subtree:add_le(fields.cbor_type, buffer(5,1), cbor_type_bits)
		subtree:add_le(fields.data_size , buffer(5,1), data_size_bits)
		return consumed + settings_bool(buffer(4), pinfo, subtree, bool_fun[1])
	end		

	if  data_type== 0x09 then
		return consumed + add_unknown_bool(buffer(4),pinfo,subtree)
	else
		return consumed + add_unknown_field(buffer(4),data_size_bits, pinfo,subtree)
	end
end

-- only adds padding at the packet end 
local function is_packet_end(buffer)
	-- 4 byte is the minimum header, only test that much for 0xff
	-- start at begginning of tvb towards the end
	if buffer:len() == 0 then
		return false -- no padding needed
	end

	for i=0,math.min(4,buffer:len()-1) do
		if buffer(i,1):le_uint() ~= 0xff then
			return false
		end	
	end
	return true
end

local function add_padding(buffer,pinfo,tree)	
	tree:add_le(fields.padding, buffer(0,buffer:len()))
end

local function bulkvalues(buffer,pinfo,tree)	
	print("victron: bulk:"..buffer(0,4):bytes():tohex())

	-- get the length of the packet buffer (Tvb).
	local pktlen = buffer:len()
	local bytes_consumed = 0

	while bytes_consumed < pktlen do
		-- test for minimum header length
		if pktlen - bytes_consumed < MINIMUM_PACKET_SIZE then -- same minimum size as in single_Value, keeps from adding empty 'bulk value' entries
			tree:add(fields.leftover,buffer(bytes_consumed))
			print("victron: bulk before need more bytes")
			pinfo.desegment_offset = bytes_consumed 
			pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
			return bytes_consumed
		end
		-- test for known header. can be unknown or missing bytes
		if command_categories[buffer(0,4):le_uint()] == nil then -- maybe not neccessary, delete after debug
			print("victron: category unknown, need previous bytes:"..buffer(0,4):bytes():tohex() )
			pinfo.desegment_offset = -1
			pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
			return 0
		end
		-- actually dissect
		local subtree = tree:add(victron_protocol, "Bulk Value", buffer)
		local result = single_value(buffer(bytes_consumed), pinfo, subtree)
		if result == 0 then
			subtree:append_text(" [not enough bytes to decode]")
			subtree:set_hidden(true)
			--bytes_consumed = bytes_consumed + 6 --add length of header
			tree:add(fields.leftover,buffer(bytes_consumed))
			print("victron: bulk need more bytes(consumed:"..bytes_consumed..")next: "..buffer(bytes_consumed,4):bytes():tohex())
			print("whole buffer:"..buffer():bytes():tohex())
			if pinfo.desegment_offset == -1 then
				pinfo.desegment_offset = bytes_consumed -- -6
			end -- else it was set already in single_value
			pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
			return bytes_consumed 
		end
		print("resul:"..result)
		bytes_consumed = bytes_consumed + result
		-- post-dissect check if only padding left over
		if is_packet_end(buffer(bytes_consumed)) then
			add_padding(buffer(bytes_consumed), pinfo, tree)
			return pktlen
		end
	end
	print("victron: bulk complete")

	if buffer(pktlen-2,2):le_uint() == 0xffff then
		print("final paekt found")
		pinfo.desegment_offset = pktlen
		pinfo.desegment_len = 0
	end
	return bytes_consumed
end


function sending(buffer, pinfo, tree)
	local subtree = prepare_subtree(buffer, tree)
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
	pinfo.cols.info = ""
	-- first 3 byte are handled by btatt dissector
	-- subtree:add_le(fields.command_dir, buffer(0,1)):append_text("send CMD")
	-- subtree:add_le(fields.characteristic, buffer(1,2))
	

	
	if opcode == 0x52 then
		sending(buffer, pinfo, tree)
		return
	end
	local bytes_consumed = 0

	if buffer:len() < MINIMUM_PACKET_SIZE then
		print("victron generic: header too short")
		pinfo.desegment_offset = -1
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0
	end

	if command_categories[buffer(0,4):le_uint()] == nil then
		print("victron: category unknown, need previous bytes:"..buffer(0,4):bytes():tohex() )
		pinfo.desegment_offset = -1
		pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
		return 0
	end

	local subtree = prepare_subtree(buffer, tree, packet_type)

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
