TOPOLOGY ?= ../../build-tools/topology/topology2/production/ipc3/sof-cht-rt5677.tplg
OUTPUT ?= artifacts

.PHONY: package test

package:
	bash build-deb.sh "$(TOPOLOGY)" "$(OUTPUT)"

test: package
	bash check-package.sh "$(OUTPUT)/sof-topology-yogabook_1.0.1_all.deb"
