# ! Package information

package_version=$(shell cat package.json|grep version|cut -d\" -f4)
package_name=$(shell cat package.json|grep name|cut -d\" -f4)
package_author=$(shell cat package.json|grep author|cut -d\" -f4)
package_githash=$(shell git rev-parse --short HEAD)

# ! Lib targets

lib_src=$(shell find src/* -name "*.coffee" ! -name 'pack.coffee')
lib_files=$(subst src,lib,$(lib_src:.coffee=.js))
doc_files=$(subst src,docs,$(lib_src:.coffee=.html))

# ! Generic targets

lib: $(lib_files)

doc: $(doc_files) docs/pack.html

dist: dist/full.pack

all: doc dist

clean:
	@echo "Clean"
	@rm -rf docs/
	@rm -rf build/
	@rm -rf lib/

clean_all: clean
	@echo "Remove node_modules directory"
	@rm -rf dist
	@rm -rf node_modules

install:
	@npm install

# ! Magic

lib/%.js: src/%.coffee
	@mkdir -p $(shell dirname $@)
	@coffee -p $< > $@
	@echo "Compile: $@"

docs/%.html: src/%.coffee
	@mkdir -p $(shell dirname $@)
	@docco -o $(dir $@) $<

build/%.module: lib/%.js
	@mkdir -p $(shell dirname $@)
	@echo Module: $(basename $(subst build/,,$@))
	@echo "register('$(basename $(subst build/,,$@))', function(module, require) {" > $@.tmp
	@cat $< >> $@.tmp
	@echo "});" >> $@.tmp
	@mv $@.tmp $@

build/full.pack: build/main.module
	@cat $^ > $@
	@echo "Pack: $(basename $@)"

build/banner:
	@echo "Banner"
	@mkdir -p $(shell dirname $@)
	@echo "/* $(package_name) - v$(package_version) ($(package_githash)) - (c) 2012 $(package_author) */" > $@

build/header: lib/pack.js
	@echo "Header"
	@grep -B 1000 'insertmodshere = true' $< > $@

build/footer: lib/pack.js
	@echo "Footer"
	@grep -A 1000 'insertmodshere = true' $< > $@

dist/$(package_name)-%-$(package_version).js: build/banner build/header build/%.pack build/footer
	@mkdir -p $(shell dirname $@)
	@cat $^ > $@
	@echo "Save: $@"

dist/$(package_name)-%-$(package_version).min.js: dist/$(package_name)-%-$(package_version).js build/banner
	@uglifyjs $< -c -m >> $@.tmp
	@echo "Compact: $@"
	@mv $@.tmp $@

dist/%.pack: dist/$(package_name)-%-$(package_version).min.js
	@touch $<

.SECONDARY:

.PHONY: lib dist all clean clean_all install
