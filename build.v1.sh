#!/bin/bash

flutter_bin=${FLUTTER_HOME}/bin
home=${PROJECT_HOME}
echo $home

echo "start"
# ${flutter_bin}/flutter --no-color build appbundle --release
${flutter_bin}/flutter --no-color build apk --no-shrink --release

pushd ${home}/android/
# ./gradlew clean
./gradlew channelRelease

#cp ${fw_home}/build/app/outputs/bundle/release/app-release.aab ${temp_out}/app-google-release.aab
#cp ${fw_home}/build/app/outputs/channel/*.apk ${temp_out}/

popd
echo "done"