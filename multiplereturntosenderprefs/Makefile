include theos/makefiles/common.mk

BUNDLE_NAME = MultipleReturnToSenderPrefs
MultipleReturnToSenderPrefs_FILES = MultipleReturnToSenderPrefs.mm
MultipleReturnToSenderPrefs_INSTALL_PATH = /Library/PreferenceBundles
MultipleReturnToSenderPrefs_FRAMEWORKS = UIKit
MultipleReturnToSenderPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MultipleReturnToSenderPrefs.plist$(ECHO_END)
