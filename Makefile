#TARGET = simulator:clang::11.0
#ARCHS = x86_64

TARGET = iphone:11.2
ARCHS = arm64
PACKAGE_VERSION = 1.0.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PrideBars
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

ifneq (,$(filter x86_64,$(ARCHS)))
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
	@/Users/BlakeBoxberger/simject/bin/respring_simulator
endif

ifneq (,$(filter x86_64,$(ARCHS)))
remove::
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@rm -f /opt/simject/$(TWEAK_NAME).plist
	@/Users/BlakeBoxberger/simject/bin/respring_simulator
endif
