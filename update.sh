#!/bin/sh
set -e
HOOKS_HASH=$(cat hash)
eval $(curl https://static.runelite.net/bootstrap.json | jq -r '.artifacts[]|select(.name|startswith("injected-client"))|"BOOT_HASH="+.hash,"BOOT_NAME="+.name,"BOOT_PATH="+.path')
if [ "$HOOKS_HASH" = "$BOOT_HASH" ]; then
	exit
fi
curl $BOOT_PATH > injected-client.jar
$JAVA_HOME_21_X64/bin/java -cp updater.jar net.runelite.deob.Deob injected-client.jar deob.jar
$JAVA_HOME_21_X64/bin/java -cp updater.jar net.runelite.hook.UpdateHooks deob.jar renamed.jar hooks-unsorted.json
jq -S < hooks-unsorted.json > hooks.json
echo -n $BOOT_HASH > hash
if ! [ -z "$GITHUB_ACTIONS" ]; then
	git config --global user.name 'a'
	git config --global user.email ''
	git add hash hooks.json
	git commit -m "update $BOOT_NAME"
	git push
fi
