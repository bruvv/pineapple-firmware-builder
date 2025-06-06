#!/bin/bash
set -euo pipefail

top=$(pwd)

#use binwalk
extract_firmware() {
    binwalk -e "$top"/upgrade-"$upstream_version".bin
    echo "$upstream_version" > "$top"/configs/.upstream_version
    mkdir openwrt-cc/files
    cp -r "$top"/_upgrade-"$upstream_version".bin.extracted/squashfs-root/* "$top"/openwrt-cc/files/
    rm -rf "$top"/openwrt-cc/files/lib/modules/*
    rm -rf "$top"/openwrt-cc/files/sbin/modprobe
}

apt_get() {
    # Clean this up
    sudo apt-get update
    sudo apt-get install -y \
    git build-essential zlib1g-dev liblzma-dev python-magic subversion g++-6 \
    libncurses5-dev gawk flex quilt curl wget gcc binutils bzip2 python2.7 python-pip  \
    libssl1.0-dev xsltproc libxml-parser-perl mercurial bzr ecj cvs unzip binwalk \
    make grep diffutils libc6 time perl
}

install_binwalk() {
    cd "$top/binwalk" || exit
    ./deps.sh
    sudo python setup.py install
    cd "$top" || exit
}

first_run() {
    cd "$top" || exit
    apt_get
    git submodule update --recursive --remote
    wget https://www.wifipineapple.com/downloads/nano/latest -O upgrade-"$upstream_version".bin
    touch "$top"/configs/.upstream_version
    cp "$top/configs/gl-ar150-defconfig" "$top/openwrt-cc/.config"
    mkdir "$top"/firmware_images
    extract_firmware
}

install_scripts() {
    echo "updating openwrt"
    cd "$top/openwrt-cc" || exit
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

build_firmware() {
    echo "Everything is ready to start the build, grab some coffee this can take a long time (90 minutes or more!)"
    sleep 3
    cd "$top/openwrt-cc" || exit
    make download
    make -j"$(nproc)"
    find "$top/openwrt-cc/bin" -name "*-sysupgrade.bin" -print0 | \
    while IFS= read -r -d '' line; do
        cp "$line" "$top/firmware_images/wifi-pineapple-$upstream_version-gl-ar150-sysupgrade.bin"
        echo "[*] New build ready at - $top/firmware_images/wifi-pineapple-$upstream_version-gl-ar150-sysupgrade.bin"
    done
    cd "$top" || exit
}

full_build() {
    upstream_version=$(curl -s https://www.wifipineapple.com/downloads/nano/ | \
            python -c "import sys, json; print(json.load(sys.stdin)['version'])")
    current_version=$(cat "$top"/configs/.upstream_version)

    if [ -f "$top/configs/.upstream_version" ]; then
        echo "config file found, Upstream version=$upstream_version and latest build=$current_version. No need to update. Want to force a rebuild? Use -f."
        cd "$top" || exit
        echo "updating submodules to make sure there is a fresh build ready if needed."
        git submodule update --remote
        exit
    else
        echo "config file not found, running for the first time"
        first_run
    fi
    
    if [ "$upstream_version" \> "$current_version" ]; then
        echo "extracting firmware now."
        extract_firmware
    fi
    install_scripts
    make defconfig
    build_firmware
}

case "${1-}" in
    -f)
        echo "forcing new build."
        rm "$top"/configs/.upstream_version
        cp "$top/configs/gl-ar150-defconfig" "$top/openwrt-cc/.config"
        full_build
        ;;
    -c)
        current_version=$(cat "$top"/configs/.upstream_version)
        echo "cleaning up..."
        rm -rf "$top/_upgrade-${current_version}.bin.extracted/"
        rm -rf "$top/upgrade-${current_version}.bin"
        cd "$top/openwrt-cc" || exit
        make dirclean
        rm -f .config
        rm -rf files
        cd "$top" || exit
        echo "all cleaned up, do you want to rerun the build? Use -f"
        ;;
    "" )
        cp "$top/configs/gl-ar150-defconfig" "$top/openwrt-cc/.config"
        full_build
        ;;
    *)
        echo "Usage: $0 [-f] [-c]" >&2
        exit 1
        ;;
esac
