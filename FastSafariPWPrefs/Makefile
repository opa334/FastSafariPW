include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FastSafariPWPrefs
FastSafariPWPrefs_FILES = FSPRootListController.m
FastSafariPWPrefs_INSTALL_PATH = /Library/PreferenceBundles
FastSafariPWPrefs_FRAMEWORKS = UIKit
FastSafariPWPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FastSafariPWPrefs.plist$(ECHO_END)
