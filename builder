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
	if [ $configb = "hammerhead" ]; then
		if ! [ -d device/lge/hammerhead ]; then
			echo -e "${bldred}N5: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_lge_hammerhead.git device/lge/hammerhead
		fi
		if ! [ -d kernel/lge/hammerhead ]; then
			echo -e "${bldred}N5: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_lge_hammerhead.git kernel/lge/hammerhead
		fi
		if ! [ -d vendor/lge/hammerhead ]; then
			echo -e "${bldred}N5: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_lge_hammerhead.git vendor/lge/hammerhead
		fi
	fi
	if [ $configb = "sprout4" ]; then
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
	fi
	if [ $configb = "sprout8" ]; then
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
	fi
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

function sync_nitrogen {
	repo sync --force-sync -j$cpucores
	if [ -d device/lge/hammerhead ]; then
		cd device/lge/hammerhead
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_device_lge_hammerhead.git device/lge/hammerhead
	fi

	if [ -d kernel/lge/hammerhead ]; then
		cd kernel/lge/hammerhead
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_kernel_lge_hammerhead.git kernel/lge/hammerhead
	fi

	if [ -d vendor/lge/hammerhead ]; then
		cd kernel/lge/hammerhead
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_vendor_lge_hammerhead.git vendor/lge/hammerhead
	fi

	if [ -d device/google/sprout4 ]; then
		cd device/google/sprout4
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_device_google_sprout4.git device/google/sprout4
	fi

	if [ -d device/google/sprout8 ]; then
		cd device/google/sprout8
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_device_google_sprout8.git device/google/sprout8
	fi

	if [ -d kernel/google/sprout ]; then
		cd kernel/google/sprout
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_kernel_google_sprout.git kernel/google/sprout
	fi

	if [ -d vendor/google/sprout ]; then
		cd kernel/google/sprout
		git pull -f
		cd ~/$nitrogen_dir
	else
		git clone https://github.com/nitrogen-devs/android_vendor_google_sprout.git vendor/google/sprout
	fi
}

while read -p "Please choose your option:
 1. Install soft, libs
 2. Sync sources (force sync)
 3. Clean (clean all build files)
 4. Build LG Optimus G (geehrc)
 5. Build LG Optimus G (geeb)
 6. Build LG Nexus 4 (mako)
 7. Build LG Nexus 5 (hammerhead)
 8. Build Google Sprout 4
 9. Build Google Sprout 8
 10. Build all (for high-performance computers)
 11. Abort
:> " cchoice
do

case "$cchoice" in
	1 )
		sudo apt-get install bison build-essential curl flex lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop openjdk-7-jdk openjdk-7-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev git-core make phablet-tools gperf
		echo -e "Done!"
		;;
	2 )
		sync_nitrogen
		echo "Done!"
		;;
	3 )
		make clean
		;;
	4 )
		configb=geehrc
		build_nitrogen
		break
		;;
	5 )
		configb=geeb
		build_nitrogen
		break	
		;;
	6 )
		configb=mako
		build_nitrogen
		break
		;;
	7 )
		configb=hammerhead
		build_nitrogen
		break
		;;
	8 )
		configb=sprout4
		build_nitrogen
		break
		;;
	9 )
		configb=sprout8
		build_nitrogen
		break
		;;
	10 )
		configb=geehrc
		build_nitrogen
		configb=geeb
		build_nitrogen
		configb=mako
		build_nitrogen
		configb=hammerhead
		build_nitrogen
		configb=sprout4
		build_nitrogen
		configb=sprout8
		build_nitrogen
		break
		;;
	11 )
		break
		;;
esac

done
