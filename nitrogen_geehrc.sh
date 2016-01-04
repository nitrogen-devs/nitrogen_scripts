#!/bin/bash

cd nitrogen

export USE_PREBUILT_CHROMIUM=1
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache/nitrogen


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

# setup environment
echo -e "${bldblu}Setting up environment ${txtrst}"

# set ccache due to your disk space,set it at your own risk
prebuilts/misc/linux-x86/ccache/ccache -M 50G
. build/envsetup.sh
#breakfast geehrc
source build/envsetup.sh
echo -e ""
echo -e "${bldblu}Starting compilation ${txtrst}"
# get time of startup
res1=$(date +%s.%N)

#brunch geehrc

lunch nitrogen_geehrc-userdebug

make -j8 otapackage

# finished? get elapsed time
res2=$(date +%s.%N)

cd out/target/product/geehrc/
FILE=$(ls *.zip | grep Nitrogen)

if [ -f ./$FILE ]
then
    cp $FILE /home/mr_mex/$FILE
else
echo "Fail"
fi

cd
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"