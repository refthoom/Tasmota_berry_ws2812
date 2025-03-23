##########################################################
# berry script to show sensor values on a pixel strip, in 
# three different colors for three sequential ranges.
#
# Developed march 2025 with an 'ESP32-C3 super mini',
# 'SCD41 CO2 sensor' and '16 pixel WS2812 RGB LED Ring',
# on 'release-Tasmota32 14.4.1' and with my honest 
# appreciation for help from @sfromis
#
# User values to configure are any sensor as long as it
# uses integer values, maximum sensor range, pixel 
# colors, 3 color ranges, number of pixels per color
# range, # minimum brightness, minimum pixels to be on and
# fixed or dynamic brightness (to draw extra attention to
# high values)
#
# Use this script as file 'WS2812_scale.be': 
# main >> tools >> manage files system >> 
# create or upload. 
#
# Then, if not already there, create file autoexec.be 
# and add this line in there, without the #
# load('WS2812_scale.be')
#
# Then restart Tasmota from the main menu.
##########################################################

# json lib to read sensors
import json # leave out when repated testing in REPL
# math lib to round up to step value
import math
# sensor name (see console /SENSOR lines to get the correct name)
var sensor_name = 'SCD40'
var sensor_data_A = 'CarbonDioxide'
var sensor_data_B = 'eCO2'
# define values for the pixels related to the sensor values
var sensor_step = 100 # sensor value step for each pixel
var sensor_start_range = 400
var sensor_first_threshold = 800 # three colors means two thresholds where the color changes
var sensor_second_threshold = 1200
var sensor_end_range = 1700
var use_snsr_ceil = 1 # boolean, if 1 round up the sensor values, else leave as is
# number of pixels per color and other settings
# sensor_step determines the number of pixels being used
var pixels_min = 1 # fixed number of pixels to be lit on beginning of the scale
var pixels_skip = 2 # number of pixels to skip for display purposes
# first range
var pixels_a = 0
if (sensor_first_threshold - sensor_start_range) > 0
	pixels_a = (sensor_first_threshold - sensor_start_range) / sensor_step
	# print ('pixels_a ', pixels_a) # debug
end
# second range
var pixels_b = 0
if (sensor_second_threshold - sensor_first_threshold) > 0
	pixels_b = (sensor_second_threshold - sensor_first_threshold) / sensor_step
	# print ('pixels_b ', pixels_b) # debug
end
# third range
var pixels_c = 0
if (sensor_end_range - sensor_second_threshold) > 0
	pixels_c = (sensor_end_range - sensor_second_threshold) / sensor_step
	# print ('pixels_c ', pixels_c) # debug
end
var pixels_all = pixels_a + pixels_b + pixels_c # total pixels used on the strip
# colors to be used on the strip in hex format 0xRRGGBB
var pixels_a_color = 0x00FF00 # green
var pixels_b_color = 0xFFFF00 # yellow
var pixels_c_color = 0xFF0000 # red
# define luminosity (brightness) boundaries
var lum_min = 64 # appr. 25%
var lum_max = 191 # appr. 75%
var lum_fix = 0 # boolean, if 1 then use lum_min as fixed value for brightness
# define the luminosity step per pixel
var lum_step = int((lum_max - lum_min) / pixels_all)
# define and initiate the strip
var strip = global.strip
if global.strip == nil
	global.strip = Leds(pixels_all, gpio.pin(gpio.WS2812, 1))
end

# calculate sensor value
#############################
def calc_sensor()
	var sensor = 0
	var tasm_read = tasmota.read_sensors()
	if tasm_read
		var sensors = json.load(tasm_read)
		var sensorA = sensors[sensor_name][sensor_data_A]
		var sensorB = sensors[sensor_name][sensor_data_B]
		sensor = int((sensorA + sensorB)/2)
		# print ('sensor reading ',sensor) # debug
		if !sensor # 0 defines as false
			print ('sensor value ',sensor_name,' is zero')
		else
			return sensor
		end
	else
		print('tasmota sensors data not avaliable') # debug
	end
end
#############################

# calculate number of pixels that are on, derived from the sensor value
#############################
def calc_num_pxs(snsr)
	# calculate the number of pixels to be lit up
	var nums = pixels_min # minimum pixels to be on
	if snsr > 0
		if (snsr - sensor_start_range) > 0
			if use_snsr_ceil
				nums = int( math.ceil( ( snsr - sensor_start_range ) / real(sensor_step) ) )
				# print('nums_ceil is ', nums) # debug
			else 
				nums = int((snsr - sensor_start_range) / sensor_step)
				# print('nums_int is ', nums) # debug
			end
		end
		if nums >= pixels_all
			nums = pixels_all
		end
		if nums <= pixels_min
			nums = pixels_min
		end
	else
		print('sensor value is zero') # debug
	end
	# print('pixels to lite up ',nums) # debug
	return nums
end
#############################

# luminosity (brightness) of pixels that are on
#############################
def calc_lum_pxs(numpxs)
	var lums = lum_min
	if !lum_fix
		lums = lum_min + (numpxs * lum_step)
		if lums > lum_max
			lums = lum_max
		end
	end
	# print('brightness ',lums) # debug
	return lums
end
#############################

# set the pixels and push to buffer
#############################
def show(test)
	strip.clear() # reset the strip buffer data
	var sens_val = calc_sensor() # get the sensor value
	var num_pxs = calc_num_pxs(sens_val) # get the number of pixels to be on
	if test # debug, manually set number of pixels
		if test > pixels_all
			num_pxs = pixels_all
		else
			num_pxs = test
		end
	end
	var lum_pxs = calc_lum_pxs(num_pxs) # get the brightness
	# set the colors
	var strip_color = 0x000000 # means is off
	for i : 0..num_pxs - 1
		if i <= (pixels_a - 1) # green range
			strip_color = pixels_a_color
		end
		if i > (pixels_a - 1) && i <= (pixels_a + pixels_b - 1) # yellow range
			strip_color = pixels_b_color
		end
		if i > (pixels_a + pixels_b - 1) # red range
			strip_color = pixels_c_color
		end
		strip.set_pixel_color((i + pixels_skip), strip_color, lum_pxs) # push to buffer
	end
	strip.show() # write buffer to pixels
end
#############################
# manually type show() in REPL for testing, with or without a test value

# initiate cron to show results every minute
tasmota.remove_cron('show_scale')
tasmota.add_cron('1 * * * * *',/->show(),'show_scale')
