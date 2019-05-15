# Last Update: 2018-02-07
# Author: Gloomy Sunday

Tag_Version="$1"

if [${Tag_Version} = ""]; then 
	echo "You Need Input A Tag Version"
	exit 1
else
	echo "\nSubmit Verson: ${Tag_Version}\n"
	File_Path=$(cd `dirname $0`; pwd)
	Module_Path=${File_Path%/*}
	Module_File=`find $Module_Path -name *.podspec`
	Module_Code_Path="${Module_Path}/Example"
	Module_Name="${Module_File##*/}"
	Module_Name="${Module_Name%.*}"
	Old_Version="$(grep -r 's.version* ' ${Module_File} |awk -F = '{print $2}')"

  #  1. Lint to Cocoapods
  echo "\n Cocoapods lint..."
  ($(cd ${Module_Path}; pod lib lint ${Module_File})) ||  { echo "\nFailure...."; exit 1; }

	#  2.更新 jazzy documents

	echo "\nBegin Generate jazzy Document....\n"
  ($(cd ${Module_Code_Path}; jazzy -m ${Module_Name} -x -workspace,${Module_Name}.xcworkspace,-scheme,${Module_Name} -c -a Gloomy.Meng -u https://gloomymeng.io/ -g https://github.com/GloomyMeng -o ${Module_Path}/docs --min-acl internal --exclude=/*/*Typealiases.swift)) ||  { echo "\nFailure...."; exit 1; }
	echo "\nGit Commit For Document Updated "
  ($(cd ${Module_Path};git add .; git commit -m "Updated: code documents updated")) ||  { echo "\nFailure...."; exit 1; }

  #  3.更新 .podspec 版本号
  echo "\nBegin Update Podspec Version...."
  ($(sed -i "" "s/${Old_Version}/ '${Tag_Version}'/g" ${Module_File})) ||  { echo "\nFailure...."; exit 1; }
  echo "\nGit Commit For Podspec Updated"
  ($(cd ${Module_Path};git add .; git commit -m "Updated: Podspec Version Updated")) ||  { echo "\nFailure...."; exit 1; }

   #  4.GIT PUSH & GIT TAG PUSH
  echo "\nGit Push...."
  ($(cd ${Module_Path}; git push)) ||  { echo "\nFailure...."; exit 1; }
  echo "\nAdd Tag...."
  ($(cd ${Module_Path};git tag -a ${Tag_Version} -m 'Release Version For Cocoapods')) || { echo "\nFailure...."; exit 1; }
  echo "\nGit Push Tag...."
  ($(cd ${Module_Path}; git push origin ${Tag_Version})) || { echo "\nFailure...."; exit 1; }

  #  5. Thunk to Cocoapods
  echo "\n Cocoapods Push..."
  ($(cd ${Module_Path}; pod trunk push --verbose ${Module_File})) || { echo "\nFailure...."; exit 1; }

	echo "\nSuccess...."
fi
