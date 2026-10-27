# SPDX-License-Identifier: 0BSD

CLFLAGS ::= /options:strict /guard:cf /guard:ehcont
CLFLAGS_AMD64 ::= /arch:SSE4.2 $(CLFLAGS)
CLFLAGS_AARCH64 ::= /arch:armv8.2 $(CLFLAGS) /guard:signret

LINKFLAGS ::= /DEPENDENTLOADFLAG:0x800 /GUARD:CF /GUARD:EHCONT
LINKFLAGS_AMD64 ::= $(LINKFLAGS) /CETCOMPAT
LINKFLAGS_AARCH64 ::= $(LINKFLAGS)

BUILD_W32_OPTIONS ::= --spectre --without-guile
