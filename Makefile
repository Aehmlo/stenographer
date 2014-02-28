export TARGET=iphone:clang:7.0:7.0
export ARCHS=armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = TelegramLauncher
TelegramLauncher_FILES = Tweak.xm
TelegramLauncher_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
