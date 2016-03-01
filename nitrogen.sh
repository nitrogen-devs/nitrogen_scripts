#!/bin/bash

cd nitrogen

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
	source build/envsetup.sh
	echo -e "${bldblu}Starting compilation ${txtrst}"
	res1=$(date +%s.%N)
	lunch nitrogen_$configb-userdebug
	make otapackage
	res2=$(date +%s.%N)
	cd
	echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
}

while read -p "Please choose your option:
 1. Clean
 2. Build geehrc
 3. Build geeb
 4. Build mako
 5. Build all
 6. Sync
 7. Abort
: " cchoice
do
case "$cchoice" in
	1 )
		make clean
		cd
		break
		;;
	2 )
		configb=geehrc
		build_nitrogen
		cd
		break
		;;
	3 )
		configb=geeb
		build_nitrogen
		cd
		break	
		;;
	4 )
		configb=mako
		build_nitrogen
		cd
		break
		;;
	5 )
		configb=geehrc
		build_nitrogen
		configb=geeb
		build_nitrogen
		configb=mako
		build_nitrogen
		cd
		break
		;;
	6 )
		repo sync --force-sync
		cd device/lge/geeb
		git pull -f
		cd ../mako
		git pull -f
		cd ../../../kernel/lge/geeb
		git pull -f
		cd ../mako
		git pull -f
		cd ../../../vendor/lge/geeb
		git pull -f
		cd ../mako
		git pull -f
		cd
		echo "Done!"
		break
		;;
	7 )
		cd
		break
		;;
esac
done
