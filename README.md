# GLi-NET GL-AR150 WiFi PINEAPPLE FIRMWARE BUILDER

> all of the fancy work, none of the fancy name

---

## MAIN

### Clone

```
git clone https://github.com/d1slact0r/gl-ar150-pineapple-firmware-builder.git
```

### Run

The most common way to build the firmware is simply to run `build_pineapple.sh`. This will check for newer upstream code, download it and compile the firmware for the ar-150. If your currently synced code/built firmware is at its newest, nothing will be done. 
There are several flags you can use though. 
- `-f` will force a build. Traditionally, if the currently synced upstream code is at its most current, the script will not build the code if it was already built on said codebase. This will force a rebuild to take place. 
- `-c` will make a clean build. This will delete all upstream code, download the most recent (again) and compile the firmware. 
