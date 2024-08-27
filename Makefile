BASE = .
SRCDIR = $(BASE)/src
LIBDIR = $(BASE)/lib
DBGDIR = $(BASE)/armdebug/Debugger
CPUINCDIR = $(BASE)/include
STARTUPDIR = $(BASE)/startup
TOOLSDIR = $(BASE)/tools

DATE_FMT = +%Y-%m-%dT%H:%M
ifndef SOURCE_DATE_EPOCH
    SOURCE_DATE_EPOCH = $(shell git log -1 --pretty=%ct)
endif
BUILD_DATE ?= $(shell LC_ALL=C date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
	      || LC_ALL=C date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
	      || LC_ALL=C date -u "$(DATE_FMT)")

TARGET = nxt_firmware

# Set to 'y' to enable embedded debuger.
ARMDEBUG = n

ARM_SOURCES =
THUMB_SOURCES = c_button.c c_cmd.c c_comm.c c_display.c c_input.c c_ioctrl.c \
		c_loader.c c_lowspeed.c c_output.c c_sound.c c_ui.c \
		d_bt.c d_button.c d_display.c d_hispeed.c d_input.c \
		d_ioctrl.c d_loader.c d_lowspeed.c d_output.c d_sound.c \
		d_timer.c d_usb.c \
		m_sched.c \
		sscanf.c \
		Cstartup_SAM7.c

ASM_ARM_SOURCE = Cstartup.S
ASM_THUMB_SOURCE =

BITMAPS = Cursor Display Fail Info LowBattery Ok Wait \
	  RCXintro_1 RCXintro_2 RCXintro_3 RCXintro_4 RCXintro_5 RCXintro_6 \
	  RCXintro_7 RCXintro_8 RCXintro_9 RCXintro_10 RCXintro_11 \
	  RCXintro_12 RCXintro_13 RCXintro_14 RCXintro_15 RCXintro_16 \
	  Test1 Test2

ICONS = Connections Devices Font Icons Port Running Status Step

MENUS = Mainmenu \
	Submenu01 Submenu02 Submenu03 Submenu04 Submenu05 Submenu06 Submenu07

vpath %.c $(SRCDIR)
vpath %.c $(LIBDIR)
vpath %.c $(STARTUPDIR)
vpath %.S $(STARTUPDIR)

INCLUDES = -I$(BASE) -I$(CPUINCDIR)

MCU = arm7tdmi
STARTOFUSERFLASH_DEFINES = -DSTARTOFUSERFLASH_FROM_LINKER=1
VERSION_DEFINES = -D'BUILD_DATE="$(BUILD_DATE)"'
DEFINES = -DPROTOTYPE_PCB_4 -DNEW_MENU -DROM_RUN -DVECTORS_IN_RAM \
	  $(STARTOFUSERFLASH_DEFINES) $(VERSION_DEFINES)
OPTIMIZE = -Os -fno-strict-aliasing \
	   -ffunction-sections -fdata-sections
WARNINGS = -Wall -W -Wundef -Wno-unused -Wno-format
THUMB_INTERWORK = -mthumb-interwork
SPECS = --specs=picolibc.specs
CFLAGS = -g -mcpu=$(MCU) $(THUMB) $(THUMB_INTERWORK) \
	 $(WARNINGS) $(OPTIMIZE) $(SPECS)
ASFLAGS = -g -mcpu=$(MCU) $(THUMB) $(THUMB_INTERWORK) \
	  $(SPECS)
CPPFLAGS = $(INCLUDES) $(DEFINES) -MMD
LDSCRIPT = $(LIBDIR)/nxt.ld
LDFLAGS = -nostdlib -T $(LDSCRIPT) -Wl,--gc-sections
LDLIBS = -lc -lm -lgcc

ifeq ($(ARMDEBUG),y)
ASM_ARM_SOURCE += abort_handler.S undef_handler.S debug_hexutils.S \
                  debug_stub.S debug_comm.S debug_opcodes.S \
                  debug_runlooptasks.S
vpath %.S $(DBGDIR)
DEFINES += -DARMDEBUG
INCLUDES += -I$(DBGDIR)
endif

CROSS_COMPILE = arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
OBJDUMP = $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy

FWFLASH = fwflash

ARM_OBJECTS = $(ARM_SOURCES:%.c=%.o) $(ASM_ARM_SOURCE:%.S=%.o)
THUMB_OBJECTS = $(THUMB_SOURCES:%.c=%.o) $(THUMB_ARM_SOURCE:%.S=%.o)
OBJECTS = $(ARM_OBJECTS) $(THUMB_OBJECTS)

BITMAPS_SOURCES = $(BITMAPS:%=%.h)
ICONS_SOURCES = $(ICONS:%=%.h)
MENUS_SOURCES = $(MENUS:%=%.h)

all: bin

elf: $(TARGET).elf
bin: $(TARGET).bin
sym: $(TARGET).sym
lst: $(TARGET).lst

$(TARGET).elf: THUMB = -mthumb
$(TARGET).elf: $(OBJECTS) $(LDSCRIPT)
	$(LINK.c) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@

%.bin: %.elf
	$(OBJCOPY) --pad-to=0x140000 --gap-fill=0xff -O binary $< $@

%.sym: %.elf
	$(OBJDUMP) -h -t $< > $@

%.lst: %.elf
	$(OBJDUMP) -S $< > $@

$(THUMB_OBJECTS): THUMB = -mthumb

-include $(OBJECTS:%.o=%.d)

LAST_BUILD_DATE=none
-include version.mak
ifneq ($(LAST_BUILD_DATE),$(BUILD_DATE))
.PHONY: version.mak
version.mak:
	echo "LAST_BUILD_DATE = $(BUILD_DATE)" > $@
endif

c_ui.o: version.mak
c_ui.o: $(BITMAPS_SOURCES) $(ICONS_SOURCES) $(MENUS_SOURCES)

%.h: data/bitmaps/%.toml data/bitmaps/%.png
	python3 $(TOOLSDIR)/img2src -o $@ $^

%.h: data/icons/%.toml data/icons/%.png
	python3 $(TOOLSDIR)/img2src -o $@ $^

%.h: data/menus/%.toml
	python3 $(TOOLSDIR)/menu2src -o $@ $<

program: $(TARGET).bin
	$(FWFLASH) $(TARGET).bin

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).sym $(TARGET).lst \
	$(OBJECTS) $(OBJECTS:%.o=%.d) version.mak \
	$(BITMAPS_SOURCES) $(ICONS_SOURCES) $(MENUS_SOURCES)
