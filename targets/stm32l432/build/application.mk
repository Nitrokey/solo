include build/common.mk

# ST related
SRC = src/main.c src/init.c src/redirect.c src/flash.c src/rng.c src/led.c src/device.c
SRC += src/fifo.c src/attestation.c src/nfc.c src/ams.c src/sense.c
SRC += src/startup_stm32l432xx.s src/system_stm32l4xx.c
SRC += $(DRIVER_LIBS) $(USB_LIB)
SRC += src/gpio.c
SRC += src/user_feedback.c

# FIDO2 lib
SRC += ../../fido2/apdu.c ../../fido2/util.c ../../fido2/u2f.c ../../fido2/test_power.c
SRC += ../../fido2/stubs.c ../../fido2/log.c  ../../fido2/ctaphid.c  ../../fido2/ctap.c
SRC += ../../fido2/ctap_parse.c ../../fido2/crypto.c
SRC += ../../fido2/version.c
SRC += ../../fido2/data_migration.c
SRC += ../../fido2/extensions/extensions.c ../../fido2/extensions/solo.c
SRC += ../../fido2/extensions/wallet.c

# Crypto libs
SRC += ../../crypto/sha256/sha256.c ../../crypto/micro-ecc/uECC.c ../../crypto/tiny-AES-c/aes.c
SRC += ../../crypto/cifra/src/sha512.c ../../crypto/cifra/src/blockwise.c

OBJ1=$(SRC:.c=.o)
OBJ=$(OBJ1:.s=.o)

INC = -Isrc/ -Isrc/cmsis/ -Ilib/ -Ilib/usbd/

INC+= -I../../fido2/ -I../../fido2/extensions
INC += -I../../tinycbor/src -I../../crypto/sha256 -I../../crypto/micro-ecc
INC += -I../../crypto/tiny-AES-c
INC += -I../../crypto/cifra/src -I../../crypto/cifra/src/ext

SEARCH=-L../../tinycbor/lib

ifndef LDSCRIPT
LDSCRIPT=linker/stm32l4xx.ld
endif

CFLAGS= $(INC)

TARGET=solo
HW=-mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb

# Solo or Nucleo board
CHIP=STM32L432xx

DEBUG ?= 0

DEFINES = -DDEBUG_LEVEL=$(DEBUG) -D$(CHIP) -DAES256=1  -DUSE_FULL_LL_DRIVER -DAPP_CONFIG=\"app.h\" $(EXTRA_DEFINES)

CFLAGS=$(INC) -c $(DEFINES)   -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -fdata-sections -ffunction-sections \
	-fomit-frame-pointer $(HW) $(VERSION_FLAGS) -Os -g3
LDFLAGS_LIB=$(HW) $(SEARCH) -specs=nano.specs  -specs=nosys.specs  -Wl,--gc-sections -lnosys
LDFLAGS_INFO=-Wl,--print-memory-usage -Wl,--print-gc-sections
LDFLAGS=$(HW) $(LDFLAGS_LIB) -T$(LDSCRIPT) -Wl,-Map=$(TARGET).map,--cref -Wl,-Bstatic -ltinycbor $(LDFLAGS_INFO)

ECC_CFLAGS = $(CFLAGS) -DuECC_PLATFORM=5 -DuECC_OPTIMIZATION_LEVEL=4 -DuECC_SQUARE_FUNC=1 -DuECC_SUPPORT_COMPRESSED_POINT=0


.PRECIOUS: %.o
include build/buildinfo.mk

all: $(TARGET).elf
	$(SZ) $^

%.o: %.c $(LDSCRIPT)
	@echo "*** $<"
	@$(CC) $< $(HW)  $(CFLAGS) -o $@

../../crypto/micro-ecc/uECC.o: ../../crypto/micro-ecc/uECC.c
	@echo "*** $<"
	@$(CC) $^ $(HW)  -O3 $(ECC_CFLAGS) -o $@

%.elf: $(OBJ)
	@echo $(CC) 'FILES' $(HW) $(LDFLAGS) -o $@
	@$(CC) $^ $(HW) $(LDFLAGS) -o $@ 2>&1 | tee $(TARGET)-linking.buildinfo
	@echo "*** Built version: $(VERSION_FLAGS)"
	@echo "*** Built flags: $(DEFINES)"
	@echo "*** Built CFLAGS: $(CFLAGS)"

%.hex: %.elf $(TARGET).buildinfo
	$(SZ) $<
	$(CP) -O ihex $< $(TARGET).hex
	$(CP) -O binary $< $(TARGET).bin

clean:
	@rm -f *.o src/*.o *.elf  bootloader/*.o $(OBJ) $(LDSCRIPT)


cbor:
	cd ../../tinycbor/ && make clean
	cd ../../tinycbor/ && make CC="$(CC)" AR=$(AR) \
LDFLAGS="$(LDFLAGS_LIB)" \
CFLAGS="$(CFLAGS) -Os -g3  -DCBOR_PARSER_MAX_RECURSIONS=3"


ifndef PAGES
PAGES=64
$(warning PAGES is not defined - setting to new value: "$(PAGES)")
endif
$(LDSCRIPT): $(LDSCRIPT).in
	sed 's/__PAGES__/$(PAGES)/g' < $< >$@
