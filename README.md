# WORK IN PROCESS!
This is still a work in process, it's for education purposes only. It makes our gl-ar150 run openwrt with HAK5 pineapples skin. The only thing that is _not_ working is the pineapd.
in the pineapd.bin there is a hardware check but I am still not sure what check this is. I will try and debug it and update this build from time to time. if you want to help out let me know!

## Issues
If you have something that is missing in the build (like firmware) let me know. I made it as complete as possible but I can't know all the firmwares.

## MAIN

### Run

The most common way to build the firmware is simply to run `build_pineapple.sh`. This will check for newer upstream code, download it and compile the firmware for the ar-150. If your currently synced code/built firmware is at its newest, nothing will be done. 
There are several flags you can use though. 
- `-f` will force a build. Traditionally, if the currently synced upstream code is at its most current, the script will not build the code if it was already built on said codebase. This will force a rebuild to take place. 
- `-c` will make a clean build. This will delete all upstream code, download the most recent (again) and compile the firmware. 
