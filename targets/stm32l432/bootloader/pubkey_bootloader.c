#include "stdint.h"
#include <assert.h>
#include APP_CONFIG

#ifdef NK_TEST_MODE
#warning "Using test bootloader key"

uint8_t pubkey_boot[] = "\xb6\xd1\xd2\x83\xaa\xc9\x67\x72\x28\xdf\x4e\xca\x05\x2b\xfc\x54\x19"
                        "\x63\x2b\xb0\xe8\xec\x6d\xb2\xfa\xd4\x37\xf8\x4d\x1e\x76\x07\xa0\xc2"
                        "\xd2\x3d\xaf\x13\x4d\x39\xe2\xa4\x15\x30\xec\x1e\x5f\x23\x65\x03\x1c"
                        "\xae\x83\xe3\x43\xf9\xd1\x74\x48\x47\xec\x8f\x60\xd2";
#else
#warning "Using production bootloader key"

#if PAGES==64
#warning "Selecting prod bootloader key for pages==64"
uint8_t pubkey_boot[] = "\xd0\xdd\x90\x21\x45\x9b\x72\x72\xaa\x90\xaa\xcf\x98\x7a\x63\x3a\x4c"
                        "\xb5\x44\x96\xc5\x70\x43\x4d\x6a\xea\xd3\x0f\xba\x5d\x85\xa3\xd8\xae"
                        "\xc0\x19\x33\x50\xf1\x5d\xda\xe3\x9d\xa8\x49\x38\x68\xeb\x28\x8e\x46"
                        "\x7e\x14\xfc\x46\xa2\x95\x9b\xb0\xd6\x35\xf1\x18\x55";
#else
#warning "Selecting prod bootloader key for pages==128"
uint8_t pubkey_boot[] = "\x72\x09\xdc\x50\x1d\xff\xbf\x99\xfd\x2d\x91\x3b\x1a\x29\x6e\xbd\x91"
                        "\x74\x3a\x15\xb5\x35\xfe\xd3\x91\x9e\x6e\x5f\x66\x02\xb9\x3e\xf7\x0f"
                        "\x0e\x0a\x59\x08\xb4\x12\x54\xf6\x62\x22\xab\x00\x51\x5b\x68\x49\xe8"
                        "\x99\xb0\x23\xbe\xcd\x61\xdb\xed\x78\x6d\xfd\x6e\xe8";
#endif

#endif

const uint8_t pubkey_boot_size = sizeof(pubkey_boot)-1;

static_assert(sizeof(pubkey_boot)-1 == 64, "Invalid key size");

