#!/bin/bash

if ! [ -d ~/.ccache/nitrogen ]; then
echo -e "${bldred}No ccache directory, creating...${txtrst}"
mkdir ~/.ccache/nitrogen
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
	echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
}

while read -p "Please choose your option:
 1. Clean (clean all build files)
 2. Build LG Optimus G (geehrc)
 3. Build LG Optimus G (geeb)
 4. Build LG Nexus 4 (mako)
 5. Build all (for high-performance computers)
 6. Sync (force sync)
 7. Abort
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
		configb=geehrc
		build_nitrogen
		configb=geeb
		build_nitrogen
		configb=mako
		build_nitrogen
		break
		;;
	6 )
		repo sync --force-sync -j$cpucores
		echo "Done!"
		;;
	7 )
		break
		;;
esac
done
