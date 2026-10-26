#!/usr/bin/make -f

# SPDX-License-Identifier: 0BSD

.POSIX:

include config-upstream.mk
include config.mk

PREFIX_SOURCE_DIR ::= build/source-
SOURCE_DIR ::= $(PREFIX_SOURCE_DIR)$(UPSTREAM_VERSION)
PREFIX_PATCHED_SOURCE_DIR ::= build/patched_source-
PATCHED_SOURCE_DIR ::= $(PREFIX_PATCHED_SOURCE_DIR)$(UPSTREAM_VERSION)_$(BUILD_NUMBER)
PREFIX_BUILD_DIR ::= build/make-
PREFIX_BUILD_DIR_VERSIONED ::= $(PREFIX_BUILD_DIR)$(UPSTREAM_VERSION)_$(BUILD_NUMBER)-
BUILD_DIR_AMD64 ::= $(PREFIX_BUILD_DIR_VERSIONED)amd64
BUILD_DIR_AARCH64 ::= $(PREFIX_BUILD_DIR_VERSIONED)aarch64
PREFIX_GNUMAKE ::= build/gnumake-
PREFIX_GNUMAKE_VERSIONED ::= $(PREFIX_GNUMAKE)$(UPSTREAM_VERSION)_$(BUILD_NUMBER)-
GNUMAKE_AMD64 ::= $(PREFIX_GNUMAKE_VERSIONED)amd64.exe
GNUMAKE_AARCH64 ::= $(PREFIX_GNUMAKE_VERSIONED)aarch64.exe

# ========== ========== ========== ========== ========== ========== ==========

.PHONY: all windows-amd64 windows-aarch64
all: windows-amd64 windows-aarch64
windows-amd64: $(GNUMAKE_AMD64)
windows-aarch64: $(GNUMAKE_AARCH64)

$(GNUMAKE_AMD64): $(BUILD_DIR_AMD64)/.stamp-build
$(GNUMAKE_AARCH64): $(BUILD_DIR_AARCH64)/.stamp-build
$(GNUMAKE_AMD64) $(GNUMAKE_AARCH64):
	cp $(^D)/WinRel/gnumake.exe $@

-include config-build.mk

$(BUILD_DIR_AMD64)/.stamp-build: $(PATCHED_SOURCE_DIR)/.stamp-patched config-build.mk
	rm -rf $(@D)
	cp -pR $(PATCHED_SOURCE_DIR) $(@D)
	cd $(@D) && _CL_="$(CLFLAGS_AMD64)" _LINK_="$(LINKFLAGS_AMD64)" ./build_w32.bat $(BUILD_W32_OPTIONS)
	touch $@

$(BUILD_DIR_AARCH64)/.stamp-build: $(PATCHED_SOURCE_DIR)/.stamp-patched config-build.mk
	rm -rf $(@D)
	cp -pR $(PATCHED_SOURCE_DIR) $(@D)
	cd $(@D) && _CL_="$(CLFLAGS_AARCH64)" _LINK_="$(LINKFLAGS_AARCH64)" ./build_w32.bat --arm64 $(BUILD_W32_OPTIONS)
	touch $@

-include patch.mk

$(SOURCE_DIR)/.stamp-source: config-upstream.mk
	rm -rf $(@D).tmp
	mkdir -p $(@D).tmp
	$(download) $(SOURCE_ARCHIVE_URL) $(@D).tar.gz $(SOURCE_ARCHIVE_SHA3_384)
	tar -xf $(@D).tar.gz -C $(@D).tmp --strip-components=1 && rm -f $(@D).tar.gz
	rm -rf $(@D)
	mv $(@D).tmp $(@D)
	touch $@

.PHONY: check-windows-amd64 check-windows-aarch64
check-windows-amd64: $(BUILD_DIR_AMD64)/.stamp-build
check-windows-aarch64: $(BUILD_DIR_AARCH64)/.stamp-build
check-windows-amd64 check-windows-aarch64:
	cd $(^D)/tests && ./run_make_tests.bat -make ../WinRel/gnumake.exe

build/RELEASE.md: RELEASE.md.in makefile config-upstream.mk config.mk
	mkdir -p $(@D)
	sed \
		-e 's/<UPSTREAM-VERSION>/$(UPSTREAM_VERSION)/g' \
		-e 's|<SOURCE-ARCHIVE-URL>|$(SOURCE_ARCHIVE_URL)|g' \
		-e 's/<VERSION>/$(VERSION)/g' \
		-e 's|<REPOSITORY-URL>|$(REPOSITORY_URL)|g' \
		RELEASE.md.in > $@.tmp
	mv $@.tmp $@

.PHONY: clean
clean:
	rm -f $(PREFIX_SOURCE_DIR)*.tar.gz*
	rm -rf $(PREFIX_SOURCE_DIR)*/
	rm -rf $(PREFIX_PATCHED_SOURCE_DIR)*/
	rm -rf $(PREFIX_BUILD_DIR)*/
	rm -f $(PREFIX_GNUMAKE)*.exe
	rm -f build/RELEASE.md*

# ========== ========== ========== ========== ========== ========== ==========

die ::= die() { printf 'ERROR: %s\n' "$$*" >&2; exit 1; }; die
verify ::= verify() ( printf '%s  %s\n' "$$2" "$$1" | sha3sum -ca 384 || { $(die) 'SHA3-384 mismatch'; }; ); verify
download ::= download() ( curl -fL --retry 3 --retry-all-errors --connect-timeout 60 -o "$$2.tmp" "$$1" && { $(verify) "$$2.tmp" "$$3"; } && mv "$$2.tmp" "$$2"; ); download
