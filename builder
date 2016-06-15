#!/bin/bash
# Copyright (C) 2016 Nitrogen Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Nitrogen OS builder script

ver_script=2.2

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
build_img=null

# Colorize and add text parameters
red=$(tput setaf 1)			 #  red
grn=$(tput setaf 2)			 #  green
cya=$(tput setaf 6)			 #  cyan
txtbld=$(tput bold)			 # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)			 # Reset

function build_nitrogen {
	if [ $configb = "null" ]; then
		echo "Device is not set!"
		break
	fi
	repo_clone
	echo -e "${bldblu}Setting up environment ${txtrst}"
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
	. build/envsetup.sh
	clear
	echo -e "${bldblu}Starting compilation ${txtrst}"
	res1=$(date +%s.%N)
	lunch nitrogen_$configb-userdebug
	clear
	make otapackage -j$cpucores 2<&1 | tee builder.log
	res2=$(date +%s.%N)
	cd out/target/product/$configb
	FILE=$(ls *.zip | grep Nitrogen)
	if [ -f ./$FILE ]; then
		echo -e "${bldgrn}Copyng zip file...${txtrst}"
		cp $FILE ~/$nitrogen_build_dir/$FILE
	else
		echo -e "${bldred}Error copyng zip!${txtrst}"
	fi
	cd ~/$nitrogen_dir
	echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
}

function build_images {
	if [ $configb = "null" ]; then
		echo "Device is not set!"
		break
	fi
	repo_clone
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
	. build/envsetup.sh
	if [ $build_img = "null" ]; then
		echo "Img file is not set!"
		break
	fi
	if [ $build_img = "boot" ]; then
		echo "Build boot.img/kernel..."
		res1=$(date +%s.%N)
		lunch nitrogen_$configb-userdebug
		make bootimage -j$cpucores 2<&1 | tee builder.log
		res2=$(date +%s.%N)
		echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
		break
	fi
	if [ $build_img = "recovery" ]; then
		echo "Build recovery.img..."
		res1=$(date +%s.%N)
		lunch nitrogen_$configb-userdebug
		make recoveryimage -j$cpucores 2<&1 | tee builder.log
		res2=$(date +%s.%N)
		echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
		break
	fi
	if [ $build_img = "system" ]; then
		echo "Build system.img..."
		res1=$(date +%s.%N)
		lunch nitrogen_$configb-userdebug
		make systemimage -j$cpucores 2<&1 | tee builder.log
		res2=$(date +%s.%N)
		echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
		break
	fi
	if [ $build_img = "all" ]; then
		echo "Build all images..."
		res1=$(date +%s.%N)
		lunch nitrogen_$configb-userdebug
		make -j$cpucores 2<&1 | tee builder.log
		res2=$(date +%s.%N)
		echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
		break
	fi
}

function repo_device_sync {
	# GEEHRC
	if [ $configb = "geehrc" ]; then
		if [ -d device/lge/geehrc ]; then
			cd device/lge/geehrc
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d kernel/lge/geehrc ]; then
			cd kernel/lge/geehrc
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/lge/geehrc ]; then
			cd kernel/lge/geehrc
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
	# GEEB
	if [ $configb = "geeb" ]; then
		if [ -d device/lge/geeb ]; then
			cd device/lge/geeb
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d kernel/lge/geeb ]; then
			cd kernel/lge/geeb
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/lge/geeb ]; then
			cd kernel/lge/geeb
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
 	# MAKO
	if [ $configb = "mako" ]; then
		if [ -d device/lge/mako ]; then
			cd device/lge/mako
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d kernel/lge/mako ]; then
			cd kernel/lge/mako
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/lge/mako ]; then
			cd kernel/lge/mako
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
	# HAMMERHEAD
	if [ $configb = "hammerhead" ]; then
		if [ -d device/lge/hammerhead ]; then
			cd device/lge/hammerhead
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d kernel/lge/hammerhead ]; then
			cd kernel/lge/hammerhead
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/lge/hammerhead ]; then
			cd kernel/lge/hammerhead
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
	# BULLHEAD
	if [ $configb = "bullhead" ]; then
		if [ -d device/lge/bullhead ]; then
			cd device/lge/bullhead
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d kernel/lge/bullhead ]; then
			cd kernel/lge/bullhead
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/lge/bullhead ]; then
			cd kernel/lge/bullhead
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
	# SPROUT4
	if [ $configb = "sprout4" ]; then
		if [ -d device/google/sprout4 ]; then
			cd device/google/sprout4
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		# SPROUT COMMON
		if [ -d kernel/google/sprout ]; then
			cd kernel/google/sprout
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/google/sprout ]; then
			cd kernel/google/sprout
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
	# SPROUT8
	if [ $configb = "sprout8" ]; then
		if [ -d device/google/sprout8 ]; then
			cd device/google/sprout8
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		# SPROUT COMMON
		if [ -d kernel/google/sprout ]; then
			cd kernel/google/sprout
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi

		if [ -d vendor/google/sprout ]; then
			cd kernel/google/sprout
			git pull -f
			cd ~/$nitrogen_dir
		else
			repo_clone
		fi
	fi
}

function repo_clone {
	if [ $configb = "geehrc" ]; then
		if ! [ -d device/lge/geehrc ]; then
			echo -e "${bldred}geehrc: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-project/android_device_lge_geehrc.git device/lge/geehrc
		fi
		if ! [ -d kernel/lge/geehrc ]; then
			echo -e "${bldred}geehrc: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-project/android_kernel_lge_geehrc.git kernel/lge/geehrc
		fi
		if ! [ -d vendor/lge/geehrc ]; then
			echo -e "${bldred}geehrc: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-project/android_vendor_lge_geehrc.git vendor/lge/geehrc
		fi
	fi
	if [ $configb = "geeb" ]; then
		if ! [ -d device/lge/geeb ]; then
			echo -e "${bldred}geeb: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_lge_geeb.git device/lge/geeb
		fi
		if ! [ -d kernel/lge/geeb ]; then
			echo -e "${bldred}geeb: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_lge_geeb.git kernel/lge/geeb
		fi
		if ! [ -d vendor/lge/geeb ]; then
			echo -e "${bldred}geeb: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_lge_geeb.git vendor/lge/geeb
		fi
	fi
	if [ $configb = "mako" ]; then
		if ! [ -d device/lge/mako ]; then
			echo -e "${bldred}N4: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_lge_mako.git device/lge/mako
		fi
		if ! [ -d kernel/lge/mako ]; then
			echo -e "${bldred}N4: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_lge_mako.git kernel/lge/mako
		fi
		if ! [ -d vendor/lge/mako ]; then
			echo -e "${bldred}N4: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_lge_mako.git vendor/lge/mako
		fi
	fi
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
	if [ $configb = "bullhead" ]; then
		if ! [ -d device/lge/bullhead ]; then
			echo -e "${bldred}N5X: No device tree, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_device_lge_bullhead.git device/lge/bullhead
		fi
		if ! [ -d kernel/lge/bullhead ]; then
			echo -e "${bldred}N5X: No kernel sources, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_kernel_lge_bullhead.git kernel/lge/bullhead
		fi
		if ! [ -d vendor/lge/bullhead ]; then
			echo -e "${bldred}N5X: No vendor, downloading...${txtrst}"
			git clone https://github.com/nitrogen-devs/android_vendor_lge_bullhead.git vendor/lge/bullhead
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
}

function sync_nitrogen {
	if [ $sync_repo_devices = true ]; then
		repo_clone
		repo_device_sync
	fi
	repo sync --force-sync -j$cpucores
}

function setjava8 {
	while read -p "Use Java 8 for build (y/n)?" cchoice
    do
    case "$cchoice" in
	y )
		export EXPERIMENTAL_USE_JAVA8=1
		java8true="yes"
		break
		;;
	n )
		export EXPERIMENTAL_USE_JAVA8=0
		java8true="no"
		break
		;;
	* )
		echo "Invalid! Try again!"
		;;
	esac
	done
}

function set_device {
while read -p "${grn}Please choose your device:${txtrst}
 1. geehrc (LG Optimus G intl E975)
 2. geeb (LG Optimus G AT&T E970)
 3. mako (Google Nexus 4 E960)
 4. hammerhead (Google Nexus 5 D820, D821)
 5. bullhead (Google Nexus 5X H791)
 6. sprout4 (Google Sprout 4)
 7. sprout8 (Google Sprout 8)
 8. Abort
:> " cchoice
do
case "$cchoice" in
	1 )
		configb=geehrc
		break
		;;
	2 )
		configb=geeb
		break	
		;;
	3 )
		configb=mako
		break
		;;
	4 )
		configb=hammerhead
		break
		;;
	5 )
		configb=bullhead
		break
		;;
	6 )
		configb=sprout4
		break
		;;
	7 )
		configb=sprout8
		break
		;;
	8 )
		break
		;;
	* )
		echo "Invalid, try again!"
		;;
esac
done
}

function mainmenu {
	setjava8
	clear
	set_device
	clear
	if [ $configb = "null" ]; then
		device_text="Device is not set!"
	else
		device_text="Device: $configb"
	fi
	if [ $java8true = "yes" ]; then
		java8text="Java version for build: 8"
	else
		java8text="Java version for build: 7"
	fi
while read -p "${bldcya}Nitrogen OS builder script v. $ver_script ${txtrst}
  $device_text
  $java8text

${grn}Please choose your option:${txtrst}
  1. Clean build files
  2. Build rom to zip (ota package)
  3. Build boot.img
  4. Build recovery.img
  5. Build system.img
  6. Build all (all img files)
  7. Sync sources (force-sync)
  8. Sync sources and device tree (force-sync)
  9. Reset sources
  10. Install soft
  11. Exit
:> " cchoice
do
case "$cchoice" in
	1 )
		make clean && make clobber
		clear
		;;
	2 )
		build_nitrogen
		break
		;;
	3 )
		build_img="boot"
		build_images
		break
		;;
	4 )
		build_img="recovery"
		build_images
		break
		;;
	5 )
		build_img="system"
		build_images
		break
		;;
	6 )
		build_img="all"
		build_images
		break
		;;
	7 )
		sync_repo_devices=false
		sync_nitrogen
		clear
		;;
	8 )
		sync_repo_devices=true
		sync_nitrogen
		clear
		;;
	9 )
		repo forall -c git reset --hard
		clear
		;;
	10 )
		sudo apt-get install bison build-essential curl flex lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop openjdk-7-jdk openjdk-7-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev git-core make phablet-tools gperf
		clear
		;;
	11 )
		break
		;;
	* )
		echo "Invalid! Try again!"
		;;
esac
done
}

mainmenu