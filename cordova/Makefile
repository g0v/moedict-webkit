copy ::
	rsync -av --delete --copy-links base/* www

emulate :: copy
	cordova emulate ios

before_prepare :: copy
	rsync -avP ../ios/Default* platforms/ios/*/Resources/splash/

after_prepare :: before_build
	cp MoeDict-Info.plist platforms/ios/MoeDict/MoeDict-Info.plist
	find platforms/android -type f |grep xml$$ | xargs grep -l moe.dict | xargs perl -pi -e 's/moe.dict/dict.moe/g'
	@cd ../android/res && tar cf splash.tar */splash.png && cd ../../cordova/platforms/android/res && tar vxf ../../../../android/res/splash.tar && cd ../../..
	cp -Rf ../android/res/drawable/* platforms/android/res/drawable

before_build ::
	-@mkdir -p platforms/android/src/org/audreyt/dict/moe platforms/android/res/menu platforms/android/res/values
	-@rm platforms/android/src/org/audreyt/moe/dict/MoeDict.java
	cp MoeDict.java platforms/android/src/org/audreyt/dict/moe
	cp example.xml platforms/android/res/menu/example.xml
	cp strings.xml platforms/android/res/values/strings.xml
	cp ../android/*.*o* AndroidManifest.xml platforms/android

before_compile :: before_build

after_compile ::
	touch touched

platforms/android/bin/MoeDict-debug.apk :
	cordova build android

release :: platforms/android/bin/MoeDict-debug.apk
	cd platforms/android ; yes $(MOEDICT_PASSWORD) | $(run) ant release
