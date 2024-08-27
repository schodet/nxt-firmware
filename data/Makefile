BASE = ..
SRCDIR = $(BASE)/src
TOOLSDIR = $(BASE)/tools

BITMAPS = Cursor Display Fail Info LowBattery Ok Wait \
	 RCXintro_1 RCXintro_2 RCXintro_3 RCXintro_4 RCXintro_5 RCXintro_6 \
	 RCXintro_7 RCXintro_8 RCXintro_9 RCXintro_10 RCXintro_11 RCXintro_12 \
	 RCXintro_13 RCXintro_14 RCXintro_15 RCXintro_16 \
	 Test1 Test2

ICONS = Connections Devices Font Icons Port Running Status Step

MENUS = Mainmenu \
	Submenu01 Submenu02 Submenu03 Submenu04 Submenu05 Submenu06 Submenu07

ALL = $(BITMAPS:%=bitmaps/%.png) $(ICONS:%=icons/%.png) $(MENUS:%=menus/%.toml)

all: $(ALL)

vpath %.txt $(SRCDIR)
vpath %.rms $(SRCDIR)

bitmaps/%.png: %.txt
	mkdir -p bitmaps
	$(TOOLSDIR)/txt2img $< bitmaps/$*

icons/%.png: %.txt
	mkdir -p icons
	$(TOOLSDIR)/txt2img $< icons/$*

menus/%.toml: %.rms
	mkdir -p menus
	$(TOOLSDIR)/txt2img $< menus/$*

clean:
	rm -f $(ALL) $(BITMAPS:%=bitmaps/%.toml) $(ICONS:%=icons/%.toml)
