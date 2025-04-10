# Tasmota_Berry_WS2812
A berry script to show SCD41 CO2 values on a scale with a WS2812 ring-strip.

# description
This is a berry script to show sensor values on a pixel strip, in three different colors for three sequential ranges. It was developed in march 2025 with an 'ESP32-C3 super mini', an 'SCD41 CO2 sensor' and a '16 pixel WS2812 RGB LED Ring' on 'release-Tasmota32 14.4.1' and with my honest appreciation for the help I recieved from @sfromis.

Although I made this script for my own purpose of showing CO2 values, the code is setup in a way that it can be used for other sensors as well. User values to configure are;
* number of pixels in your strip,
* any sensor with integer values,
* maximum sensor range,
* minimum pixels to be on,
* 3 color ranges
* pixel colors per range
* number of pixels per color range,
* minimum brightness,
* pixels to skip at the beginning and
* fixed or dynamic brightness (increased brightness by increased number of pixels to attract attention to high values that could be dangerous).
* Also, the last line of the script sets a cron (C style), it is set to 1 minute interval. You can change this to whatever you need. Note that a high interval frequnency may impact performance of the MCU.

There is lots of comments in the script itself, but here's is the TLDR;
* The sensor value is read using the json library.
* That value is then used to calculate the number of pixels to show
* and the brightness, if not a fixed brightness is chosen.
* The strip is then initialised,
* the pixels are pushed to the strip buffer,
* while asigning the correct color(s) based on the corresponding values and color(s) that are configured.
* The function show() is called to display the result,
* which is repeated at the interval set in the cron line.

NOTE: The SCD4x sensor also takes temperature measurements. Please be aware that it is very sensitive to heat emitted from other parts in the project so those measurements may not be usable for you.

# hardware, wiring & UI config
![CO2 HW](https://github.com/user-attachments/assets/389de6d0-f899-42b8-9761-a223aa8f860a)
All parts come from Ali***ss, so look there or elsewhere for the names if you want to purchase them.

Visit [this page](https://tasmota.github.io/install/) to install Tasmota. After succesfully flashing your ESP, Tasmota wil start in AP mode. Connect your PC or phone to it and configure your wifi settings. After saving those, Tasmota will reboot again, after which it's IP address will be shown *briefly!* so keep your eyes on the screen :-) 

Then with your browser, go to the shown IP address to Tasmota's main page >> configuration >> template and fill in as shown above. Hit save and wait for reboot to finish. Then go to main >> configuration >> other, tick the box 'Activate' under 'Template'. Again hit save and wait for the reboot to finish.

Next, power down your ESP and connect your parts as shown above. After that, power on and connect to the ESP's IP address with your browser. From the main page you can test your WS2812 by using the sliders and on/off button. If that all goes nicely, continue for the berry script part below. 

# berry script
Use [the script](https://github.com/refthoom/Tasmota_berry_ws2812/blob/main/WS2812_scale.be) as file 'WS2812_scale.be'. In Tasmota web interface, go to main >> tools >> manage files system >> create or upload >> the 'WS2812_scale.be' file from this repository. Next, if not already there, create the file 'autoexec.be' and add the line 'load('WS2812_scale.be')' in there, without the '. Finally, restart Tasmota from the main menu. After restart, go to main >> tools >> console and check if autoxec.be is loaded successfully. As the cron is set to 1 minute interval, it will take at least one minute before you see any pixels light up.

# testing
There is one functionality to test the config of your pixels. After the script is *manually* loaded succesfully in the berry scripting console (copy-paste the script there), you can manually run the command 'show([number])' from the berry scripting console, where [number] is the number of pixels you want to see lit. This should show immediately but will be overriden by the script, running every minute.

# project fulfillment
Here, a piece of PVC board carries the parts.

![front_smaller](https://github.com/user-attachments/assets/a63080fa-fd56-4773-ac3e-f7aece65f87e)
![back_smaller](https://github.com/user-attachments/assets/20205be8-7ac2-4d15-9790-9687afd44001)

The way I have configured the pixel ring it will show the values on 13 of the 16 pixels. The three ranges are divided in 4 pixels green, 4 pixels yellow and 5 pixels red. The bottom 3 pixels are unused to make for an arch like appearance, to resemble something like this

![dial](https://github.com/user-attachments/assets/3ae5f58e-c3ab-448a-8f98-8d0d4b89ea78)

which comes to this (very low brightness set for my crappy camera)

![arch_smaller](https://github.com/user-attachments/assets/57104d53-ef5a-4bc0-a8e7-451aab683f03)

And yes, I know it's not all really symmetric but I'm fine with that :-)
