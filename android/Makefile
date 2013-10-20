all :: bin/MoeActivity-release.apk

run = env LC_ALL=C ANDROID_HOME=/opt/adt/sdk

bin/MoeActivity-release.apk ::
	yes $(MOEDICT_PASSWORD) | $(run) ant release

install ::
	adb install -r bin/MoeDict-release.apk

upload ::
	rsync -avzP bin/MoeDict-release.apk audreyt.org:public_html/newdict/Moe1.apk
