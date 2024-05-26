#!/bin/sh
set -e
HOOKS_HASH=$(cat hash)
eval $(curl https://static.runelite.net/bootstrap.json | jq -r '.artifacts[]|select(.name|startswith("client-patch"))|"BOOT_HASH="+.hash,"BOOT_NAME="+.name,"BOOT_PATH="+.path')
if [ "$HOOKS_HASH" = "$BOOT_HASH" ]; then
	exit
fi
curl $BOOT_PATH > client-patch.jar
unzip client-patch.jar client.patch
VANILLA_URL=$(curl https://static.runelite.net/jav_config.ws | grep runelite.gamepack | tail -c +19)
curl $VANILLA_URL > vanilla.jar
$JAVA_HOME_21_X64/bin/java -cp updater.jar net.runelite.gamepack.Patcher vanilla.jar client.patch patched.jar
$JAVA_HOME_21_X64/bin/java -cp updater.jar net.runelite.deob.Deob patched.jar deob.jar
$JAVA_HOME_21_X64/bin/java -cp updater.jar net.runelite.hook.UpdateHooks deob.jar renamed.jar hooks.json
echo -n $BOOT_HASH > hash
if ! [ -z "$GITHUB_ACTIONS" ]; then
	git config --global user.name 'updater-autobot'
	git config --global user.email ''
	git add hash hooks.json
	git commit -m "update client patch $BOOT_HASH"
	git push
fi
