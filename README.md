# WORK IN PROGRESS!
This project is still a work in progress and is for educational purposes only. It makes our GL-AR150 run OpenWrt with the Hak5 Pineapple skin.

### Firmware
If you have something that is missing in the build (like firmware) let me know. I made it as complete as possible but I can't know all the firmwares.

## How To Run

The most common way to build the firmware is simply to run `build_pineapple.sh`. This will check for newer upstream code, download it and compile the firmware for the GL-AR150. If your currently synced code or built firmware is up to date, nothing will be done.
There are several flags you can use though.
- `-f` will force a build. Traditionally, if the currently synced upstream code is at its most current, the script will not build the code if it was already built on said codebase. This will force a rebuild to take place.
- `-c` will make a clean build. This will delete all upstream code, download the most recent (again) and compile the firmware.

### Development
This repository includes a small test suite that checks the build script with
`shellcheck`. Run `tests/test_shellcheck.sh` after making changes to verify that
the script is free of linting issues. You can install the required dependency on
Ubuntu with:

```bash
sudo apt-get install shellcheck
```
