# SPDX-License-Identifier: 0BSD

PATCHES ::= \
	package_bugreport \
	quote_backticked_command_paths \
	build_w32_preserve_exit_status \
	build_w32_detect_build_tools \
	build_w32_arm64-1 build_w32_arm64-2 \
	build_w32_spectre-1 build_w32_spectre-2
PATCHES ::= $(PATCHES:%=patches/make-$(UPSTREAM_VERSION)-%.patch)

.PHONY: patch
patch: $(PATCHED_SOURCE_DIR)/.stamp-patched
$(PATCHED_SOURCE_DIR)/.stamp-patched: $(SOURCE_DIR)/.stamp-source $(PATCHES) patch.mk config.mk
	rm -rf $(@D).tmp
	cp -pR $(SOURCE_DIR) $(@D).tmp
	git -c core.autocrlf=false apply --directory=$(@D).tmp $(PATCHES)
	sed -E \
		-e 's|^(.define PACKAGE_BUGREPORT[[:space:]]+")bug-make@gnu\.org"[[:space:]]*$$|\1$(BUGREPORT_URL)"|' \
		-e 's/^(.define PACKAGE_STRING[[:space:]]+"GNU Make )$(UPSTREAM_VERSION)"[[:space:]]*$$/\1$(VERSION)"/' \
		-e 's/^(.define PACKAGE_VERSION[[:space:]]+")$(UPSTREAM_VERSION)"[[:space:]]*$$/\1$(VERSION)"/' \
		$(@D).tmp/src/mkconfig.h > $(@D).tmp/src/mkconfig.h.tmp
	[ "$$(sed -En 's/^.define PACKAGE_BUGREPORT[[:space:]]+"(.*)"[[:space:]]*$$/\1/p' $(@D).tmp/src/mkconfig.h.tmp)" = '$(BUGREPORT_URL)' ]
	[ "$$(sed -En 's/^.define PACKAGE_STRING[[:space:]]+"GNU Make (.*)"[[:space:]]*$$/\1/p' $(@D).tmp/src/mkconfig.h.tmp)" = '$(VERSION)' ]
	[ "$$(sed -En 's/^.define PACKAGE_VERSION[[:space:]]+"(.*)"[[:space:]]*$$/\1/p' $(@D).tmp/src/mkconfig.h.tmp)" = '$(VERSION)' ]
	mv $(@D).tmp/src/mkconfig.h.tmp $(@D).tmp/src/mkconfig.h
	rm -rf $(@D)
	mv $(@D).tmp $(@D)
	touch $@
