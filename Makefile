include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
export ARCHS = arm64 armv7

TWEAK_NAME = FastSafariPW
FastSafariPW_FILES = Tweak.xm
FastSafariPW_CFLAGS = -fobjc-arc
FastSafariPW_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
SUBPROJECTS += FastSafariPWPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
