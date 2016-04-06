#!/bin/bash

nitrogen_dir=nitrogen
nitrogen_build_dir=nitrogen-build

if ! [ -d ~/.ccache/$nitrogen_dir ]; then
echo -e "${bldred}No ccache directory, creating...${txtrst}"
mkdir ~/.ccache
mkdir ~/.ccache/$nitrogen_dir
fi

if ! [ -d ~/nitrogen-build ]; then
echo -e "${bldred}No nitrogen-build directory, creating...${txtrst}"
mkdir ~/$nitrogen_build_dir
fi

cpucores=$(cat /proc/cpuinfo | grep 'model name' | sed -e 's/.*: //' | wc -l)

export USE_PREBUILT_CHROMIUM=1
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache/nitrogen
configb=null

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

function build_nitrogen {
	echo -e "${bldblu}Setting up environment ${txtrst}"
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
	. build/envsetup.sh
	echo -e "${bldblu}Starting compilation ${txtrst}"
	res1=$(date +%s.%N)
	lunch nitrogen_$configb-userdebug
	make otapackage -j$cpucores
	res2=$(date +%s.%N)
	cd out/target/product/$configb
	FILE=$(ls *.zip | grep Nitrogen)
	if [ -f ./$FILE ]; then
		echo -e "${bldgrn}Copyng zip image...${txtrst}"
		cp $FILE ~/$nitrogen_build_dir/$FILE
	fi
	cd ~/$nitrogen_dir
	echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
}

while read -p "Please choose your option:
 1. Clean (clean all build files)
 2. Build LG Optimus G (geehrc)
 3. Build LG Optimus G (geeb)
 4. Build LG Nexus 4 (mako)
 5. Build Google Sprout 4
 6. Build Google Sprout 8
 7. Build all (for high-performance computers)
 8. Sync (force sync)
 9. Abort
:> " cchoice
do

case "$cchoice" in
	1 )
		make clean
		;;
	2 )
		configb=geehrc
		build_nitrogen
		break
		;;
	3 )
		configb=geeb
		build_nitrogen
		break	
		;;
	4 )
		configb=mako
		build_nitrogen
		break
		;;
	5 )
		if ! [ -d device/google/sprout4 ]; then
			echo -e "${bldred}Sprout 4: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_google_sprout4.git device/google/sprout4
		fi
		if ! [ -d kernel/google/sprout ]; then
			echo -e "${bldred}Sprout 4: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_google_sprout.git kernel/google/sprout
		fi
		if ! [ -d vendor/google/sprout ]; then
			echo -e "${bldred}Sprout 4: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_google_sprout.git vendor/google/sprout
		fi
		configb=sprout4
		build_nitrogen
		break
		;;
	6 )
		if ! [ -d device/google/sprout8 ]; then
			echo -e "${bldred}Sprout 8: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_google_sprout8.git device/google/sprout8
		fi
		if ! [ -d kernel/google/sprout ]; then
			echo -e "${bldred}Sprout 8: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_google_sprout.git kernel/google/sprout
		fi
		if ! [ -d vendor/google/sprout ]; then
			echo -e "${bldred}Sprout 8: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_google_sprout.git vendor/google/sprout
		fi
		configb=sprout8
		build_nitrogen
		break
		;;
	7 )
		if ! [ -d device/google/sprout4 ]; then
			echo -e "${bldred}Sprout 4: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_google_sprout4.git device/google/sprout4
		fi
		if ! [ -d device/google/sprout8 ]; then
			echo -e "${bldred}Sprout 8: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_google_sprout8.git device/google/sprout8
		fi
		if ! [ -d kernel/google/sprout ]; then
			echo -e "${bldred}No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_google_sprout.git kernel/google/sprout
		fi
		if ! [ -d vendor/google/sprout ]; then
			echo -e "${bldred}No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_google_sprout.git vendor/google/sprout
		fi
		configb=geehrc
		build_nitrogen
		configb=geeb
		build_nitrogen
		configb=mako
		build_nitrogen
		configb=sprout4
		build_nitrogen
		configb=sprout8
		build_nitrogen
		break
		;;
	8 )
		repo sync --force-sync -j$cpucores
		echo "Done!"
		;;
	9 )
		break
		;;
esac

done
