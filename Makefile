#####################################################################################################################################################################################################################################################################################
#  _____ ____  __  __ __  __  ____  _   _
# / ____/ __ \|  \/  |  \/  |/ __ \| \ | |
#| |   | |  | | \  / | \  / | |  | |  \| |
#| |   | |  | | |\/| | |\/| | |  | | . ` |
#| |___| |__| | |  | | |  | | |__| | |\  |
# \_____\____/|_|  |_|_|  |_|\____/|_| \_|
#

# number of processors to use for build
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
NPROC = $(shell nproc)
else ifeq ($(UNAME), Darwin)
NPROC = $(shell sysctl -n hw.physicalcpu)
endif

# Common CMake setup args
INSTALL_PREFIX :=
CMAKE_COMMON_ARGS := -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -DCMAKE_POSITION_INDEPENDENT_CODE=ON
ifdef INSTALL_PREFIX
    CMAKE_COMMON_ARGS := $(CMAKE_COMMON_ARGS) -DCMAKE_INSTALL_PREFIX=$(INSTALL_PREFIX)
endif

# use ccache if available
CCACHE := $(shell which ccache 2> /dev/null)
ifdef CCACHE
    CMAKE_COMMON_ARGS := $(CMAKE_COMMON_ARGS) -DCMAKE_CXX_COMPILER_LAUNCHER=$(shell which ccache)
endif
CMAKE_COMMON_ARGS_SHARED := -B build_shared $(CMAKE_COMMON_ARGS) -DBUILD_SHARED_LIBS=ON
CMAKE_COMMON_ARGS_STATIC := -B build_static $(CMAKE_COMMON_ARGS) -DBUILD_SHARED_LIBS=OFF

# Common CMake build args
CMAKE_BUILD_ARGS := -- -j $(NPROC)
CMAKE_BUILD_ARGS_SHARED := --build build_shared $(CMAKE_BUILD_ARGS)
CMAKE_BUILD_ARGS_STATIC := --build build_static $(CMAKE_BUILD_ARGS)

# Common CMake install args
CMAKE_INSTALL_ARGS :=
ifdef INSTALL_PREFIX
	CMAKE_INSTALL_ARGS := --prefix $(INSTALL_PREFIX)
endif

CMAKE_INSTALL_ARGS_SHARED := --install build_shared $(CMAKE_INSTALL_ARGS)
CMAKE_INSTALL_ARGS_STATIC := --install build_static $(CMAKE_INSTALL_ARGS)

#####################################################################################################################################################################################################################################################################################
# __      ________ _____   _____ _____ ____  _   _  _____
# \ \    / /  ____|  __ \ / ____|_   _/ __ \| \ | |/ ____|
#  \ \  / /| |__  | |__) | (___   | || |  | |  \| | (___
#   \ \/ / |  __| |  _  / \___ \  | || |  | | . ` |\___ \
#    \  /  | |____| | \ \ ____) |_| || |__| | |\  |____) |
#     \/   |______|_|  \_\_____/|_____\____/|_| \_|_____/
#
GOOGLETEST_VERSION := 1.14.0
CAPNPROTO_VERSION := 1.0.0
JSON_VERSION := 3.11.2
ANTLR_VERSION := 4.13.0
UHDM_VERSION := 1.74
SURELOG_VERSION := 1.74
YOSYS_VERSION := 0.33
SYNLIG_VERSION := 2023-09-19-a2c9ca8
VERILATOR_VERSION := 5.014
SIMVIEW_VERSION := 0.0.1

#####################################################################################################################################################################################################################################################################################
RELEASE_VERSION := 0.0.1

.PHONY: download
download:  ## Download all releases
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/antlr_$(ANTLR_VERSION)_amd64.deb
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/capnproto_$(CAPNPROTO_VERSION)_amd64.deb
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/json_$(JSON_VERSION)_amd64.deb
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/uhdm_$(UHDM_VERSION)_amd64.deb
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/surelog_$(SURELOG_VERSION)_amd64.deb
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/simview_$(SIMVIEW_VERSION)_amd64.deb
	wget https://github.com/dau-dev/tools/releases/download/v$(RELEASE_VERSION)/yosys_$(YOSYS_VERSION)_amd64.deb

#####################################################################################################################################################################################################################################################################################
#                         _      _            _
#                        | |    | |          | |
#  __ _  ___   ___   __ _| | ___| |_ ___  ___| |_
# / _` |/ _ \ / _ \ / _` | |/ _ \ __/ _ \/ __| __|
#| (_| | (_) | (_) | (_| | |  __/ ||  __/\__ \ |_
# \__, |\___/ \___/ \__, |_|\___|\__\___||___/\__|
#  __/ |             __/ |
# |___/             |___/
#
# https://github.com/google/googletest
#
googletest/.git:
	git clone --depth 1 --branch v$(GOOGLETEST_VERSION) https://github.com/google/googletest.git

googletest/build_shared: googletest/.git
	cd googletest && cmake $(CMAKE_COMMON_ARGS_SHARED) .
	cd googletest && cmake $(CMAKE_BUILD_ARGS_SHARED)

googletest/build_static: googletest/.git
	cd googletest && cmake $(CMAKE_COMMON_ARGS_STATIC)
	cd googletest && cmake $(CMAKE_BUILD_ARGS_STATIC)


.PHONY: googletest
googletest: googletest/build_shared googletest/build_static  ## build googletest

.PHONY: googletest/install
googletest/install: googletest/build_shared googletest/build_static  ## build and install googletest
	cd googletest && sudo cmake $(CMAKE_INSTALL_ARGS_SHARED)
	cd googletest && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)



#####################################################################################################################################################################################################################################################################################
#   _____            _       _____           _
#  / ____|          ( )     |  __ \         | |
# | |     __ _ _ __ |/ _ __ | |__) | __ ___ | |_ ___
# | |    / _` | '_ \  | '_ \|  ___/ '__/ _ \| __/ _ \
# | |___| (_| | |_) | | | | | |   | | | (_) | || (_) |
#  \_____\__,_| .__/  |_| |_|_|   |_|  \___/ \__\___/
#             | |
#             |_|
#
# https://github.com/capnproto/capnproto
#
.PHONY: capnproto/build_shared capnproto/build_static capnproto capnproto/install capnproto/debian

capnproto/.git:
	git clone --depth 1 --branch v$(CAPNPROTO_VERSION) https://github.com/capnproto/capnproto.git

capnproto/build_shared: capnproto/.git
	cd capnproto && cmake $(CMAKE_COMMON_ARGS_SHARED) .
	cd capnproto && cmake $(CMAKE_BUILD_ARGS_SHARED)

capnproto/build_static: capnproto/.git
	cd capnproto && cmake $(CMAKE_COMMON_ARGS_STATIC)
	cd capnproto && cmake $(CMAKE_BUILD_ARGS_STATIC)

capnproto: capnproto/build_shared capnproto/build_static  ## build capnproto

capnproto/install: capnproto/build_shared capnproto/build_static  ## build and install capnproto
	cd capnproto && sudo cmake $(CMAKE_INSTALL_ARGS_SHARED)
	cd capnproto && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)

capnproto/debian:  ## build debian package for capnproto
	mkdir -p capnproto/debian/DEBIAN
	printf "Package: capnproto\nVersion: $(CAPNPROTO_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: capnproto\n" > capnproto/debian/DEBIAN/control
	$(MAKE) capnproto/build_static INSTALL_PREFIX=./debian
	$(MAKE) capnproto/build_shared INSTALL_PREFIX=./debian
	$(MAKE) capnproto/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build capnproto/debian capnproto_$(CAPNPROTO_VERSION)_amd64.deb

#####################################################################################################################################################################################################################################################################################
#      _  _____  ____  _   _
#     | |/ ____|/ __ \| \ | |
#     | | (___ | |  | |  \| |
# _   | |\___ \| |  | | . ` |
#| |__| |____) | |__| | |\  |
# \____/|_____/ \____/|_| \_|
#
# https://github.com/nlohmann/json
#
.PHONY: json/build_shared json/build_static json json/install json/debian

json/.git:
	git clone --depth 1 --branch v$(JSON_VERSION) https://github.com/nlohmann/json.git

json/build_shared: json/.git
	cd json && cmake $(CMAKE_COMMON_ARGS_SHARED) .
	cd json && cmake $(CMAKE_BUILD_ARGS_SHARED)

json/build_static: json/.git
	cd json && cmake $(CMAKE_COMMON_ARGS_STATIC)
	cd json && cmake $(CMAKE_BUILD_ARGS_STATIC)

json: json/build_shared json/build_static  ## build json

json/install: json/build_shared json/build_static  ## build and install json
	cd json && sudo cmake $(CMAKE_INSTALL_ARGS_SHARED)
	cd json && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)

json/debian:  ## build debian package for json
	mkdir -p json/debian/DEBIAN
	printf "Package: json\nVersion: $(JSON_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: json\n" > json/debian/DEBIAN/control
	$(MAKE) json/build_static INSTALL_PREFIX=./debian
	$(MAKE) json/build_shared INSTALL_PREFIX=./debian
	$(MAKE) json/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build json/debian json_$(JSON_VERSION)_amd64.deb


#####################################################################################################################################################################################################################################################################################
#           _   _ _______ _      _____ 
#     /\   | \ | |__   __| |    |  __ \
#    /  \  |  \| |  | |  | |    | |__) |
#   / /\ \ | . ` |  | |  | |    |  _  /
#  / ____ \| |\  |  | |  | |____| | \ \
# /_/    \_\_| \_|  |_|  |______|_|  \_\
#
# https://www.antlr.org/
#
.PHONY: antlr/build_shared antlr/build_static antlr antlr/install antlr/debian
ifeq ($(UNAME), Linux)
ANTLR_JAR_PATH := /usr
else ifeq ($(UNAME), Darwin)
ANTLR_JAR_PATH := /usr/local
endif

antlr/antlr-$(ANTLR_VERSION)-complete.jar:
	mkdir -p antlr
	cd antlr && wget https://www.antlr.org/download/antlr4-cpp-runtime-$(ANTLR_VERSION)-source.zip
	cd antlr && unzip antlr4-cpp-runtime-$(ANTLR_VERSION)-source.zip
	wget https://www.antlr.org/download/antlr-$(ANTLR_VERSION)-complete.jar -P ./antlr

antlr/build_shared: antlr/antlr-$(ANTLR_VERSION)-complete.jar
	cd antlr && cmake $(CMAKE_COMMON_ARGS_SHARED) .
	cd antlr && cmake $(CMAKE_BUILD_ARGS_SHARED)

antlr/build_static: antlr/antlr-$(ANTLR_VERSION)-complete.jar
	cd antlr && cmake $(CMAKE_COMMON_ARGS_STATIC)
	cd antlr && cmake $(CMAKE_BUILD_ARGS_STATIC)

antlr: antlr/build_shared antlr/build_static  ## build antlr

antlr/install: antlr/build_shared antlr/build_static  ## build and install antlr
	cd antlr && sudo mkdir -p $(or $(INSTALL_PREFIX),$(ANTLR_JAR_PATH))/share/java
	cd antlr && sudo cp antlr-$(ANTLR_VERSION)-complete.jar $(or $(INSTALL_PREFIX),$(ANTLR_JAR_PATH))/share/java
	cd antlr && sudo cmake $(CMAKE_INSTALL_ARGS_SHARED)
	cd antlr && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)

antlr/debian:  ## build debian package for antlr
	mkdir -p antlr/debian/DEBIAN
	printf "Package: antlr\nVersion: $(ANTLR_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: antlr\n" > antlr/debian/DEBIAN/control
	$(MAKE) antlr/build_static INSTALL_PREFIX=./debian
	$(MAKE) antlr/build_shared INSTALL_PREFIX=./debian
	$(MAKE) antlr/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build antlr/debian antlr_$(ANTLR_VERSION)_amd64.deb


#####################################################################################################################################################################################################################################################################################
#  _    _ _    _ _____  __  __ 
# | |  | | |  | |  __ \|  \/  |
# | |  | | |__| | |  | | \  / |
# | |  | |  __  | |  | | |\/| |
# | |__| | |  | | |__| | |  | |
#  \____/|_|  |_|_____/|_|  |_|
#
# https://github.com/chipsalliance/UHDM
#
.PHONY: uhdm/build_shared uhdm/build_static uhdm uhdm/install uhdm/debian uhdm/rpm

UHDM_CMAKE_ARGS := -DUHDM_USE_HOST_GTEST=ON -DUHDM_USE_HOST_CAPNP=ON -DUHDM_BUILD_TESTS=OFF

uhdm/.git:
	git clone --depth 1 --branch v$(UHDM_VERSION) https://github.com/chipsalliance/UHDM.git uhdm

uhdm/build_shared: uhdm/.git
	cd uhdm && cmake $(UHDM_CMAKE_ARGS) $(CMAKE_COMMON_ARGS_SHARED) .
	cd uhdm && cmake $(CMAKE_BUILD_ARGS_SHARED)

uhdm/build_static: uhdm/.git
	cd uhdm && cmake $(UHDM_CMAKE_ARGS) $(CMAKE_COMMON_ARGS_STATIC)
	cd uhdm && cmake $(CMAKE_BUILD_ARGS_STATIC)

uhdm: uhdm/build_shared uhdm/build_static  ## build uhdm

uhdm/install: uhdm/build_shared uhdm/build_static  ## build and install uhdm
	cd uhdm && sudo cmake $(CMAKE_INSTALL_ARGS_SHARED)
	cd uhdm && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)

uhdm/debian:  ## build debian package for uhdm
	mkdir -p uhdm/debian/DEBIAN
	printf "Package: uhdm\nVersion: $(UHDM_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: UHDM\n" > uhdm/debian/DEBIAN/control
	$(MAKE) uhdm/build_static INSTALL_PREFIX=./debian
	$(MAKE) uhdm/build_shared INSTALL_PREFIX=./debian
	$(MAKE) uhdm/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build uhdm/debian uhdm_$(UHDM_VERSION)_amd64.deb

uhdm/rpm:  ## build rpm package for uhdm
	mkdir -p uhdm/rpm
	printf "Name: uhdm\nVersion: $(UHDM_VERSION)\nLicense: Apache-2\nRelease: 1%%{?dist}\nSummary: UHDM\nPackager: timkpaine <t.paine154@gmail.com>\nBuildArch: x86_64\n\n%%description\nUHDM\n\n%%setup\n\n%%build\n\n%%install\n\n%%clean\n\n%%post\n\n%%files\n%%{_bindir}/%%name\n\n%%changelog\n" > uhdm/rpm/uhdm.spec


#####################################################################################################################################################################################################################################################################################
#   _____                _
#  / ____|              | |
# | (___  _   _ _ __ ___| | ___   __ _
#  \___ \| | | | '__/ _ \ |/ _ \ / _` |
#  ____) | |_| | | |  __/ | (_) | (_| |
# |_____/ \__,_|_|  \___|_|\___/ \__, |
#                                 __/ |
#                                |___/
#
# https://github.com/chipsalliance/Surelog
#

.PHONY: surelog/build_shared surelog/build_static surelog surelog/install surelog/debian
# SURELOG_CMAKE_ARGS := -DSURELOG_USE_HOST_ALL=ON -DSURELOG_WITH_TCMALLOC=OFF -DSURELOG_WITH_ZLIB=ON
SURELOG_CMAKE_ARGS := -DSURELOG_USE_HOST_ANTLR=ON -DSURELOG_USE_HOST_UHDM=ON -DSURELOG_USE_HOST_JSON=ON -DSURELOG_USE_HOST_CAPNP=ON -DSURELOG_USE_HOST_GTEST=ON -DSURELOG_BUILD_TESTS=OFF -DSURELOG_WITH_TCMALLOC=OFF -DSURELOG_WITH_ZLIB=ON

surelog/.git:
	# TODO once key changes are in
	# git clone --depth 1 --branch v$(SURELOG_VERSION) https://github.com/chipsalliance/Surelog.git surelog
	git clone --depth 1 --branch master https://github.com/chipsalliance/Surelog.git surelog

surelog/build_shared: surelog/.git
	cd surelog && cmake $(SURELOG_CMAKE_ARGS) $(CMAKE_COMMON_ARGS_SHARED) .
	cd surelog && cmake $(CMAKE_BUILD_ARGS_SHARED)

surelog/build_static: surelog/.git
	cd surelog && cmake $(SURELOG_CMAKE_ARGS) $(CMAKE_COMMON_ARGS_STATIC)
	cd surelog && cmake $(CMAKE_BUILD_ARGS_STATIC)

surelog: surelog/build_shared surelog/build_static  ## build surelog

surelog/install: surelog/build_shared surelog/build_static  ## build and install surelog
	cd surelog && sudo cmake $(CMAKE_INSTALL_ARGS_SHARED)
	cd surelog && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)

surelog/debian:  ## build debian package for surelog
	mkdir -p surelog/debian/DEBIAN
	printf "Package: surelog\nVersion: $(SURELOG_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: surelog\n" > surelog/debian/DEBIAN/control
	$(MAKE) surelog/build_static INSTALL_PREFIX=./debian
	$(MAKE) surelog/build_shared INSTALL_PREFIX=./debian
	$(MAKE) surelog/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build surelog/debian surelog_$(SURELOG_VERSION)_amd64.deb



#####################################################################################################################################################################################################################################################################################
#  _   _  ___  ___ _   _ ___
# | | | |/ _ \/ __| | | / __|
# | |_| | (_) \__ \ |_| \__ \
#  \__, |\___/|___/\__, |___/
#   __/ |           __/ |
#  |___/           |___/
#
# https://github.com/YosysHQ/yosys
#
.PHONY: yosys/libs yosys yosys/install yosys/debian

ifeq ($(UNAME), Linux)
YOSYS_ARGS := CONFIG=gcc
else ifeq ($(UNAME), Darwin)
YOSYS_ARGS := CONFIG=clang
endif

yosys/.git:
	git clone --depth 1 --branch yosys-$(YOSYS_VERSION) https://github.com/YosysHQ/yosys.git

yosys/libs: yosys/.git
	cd yosys && make $(YOSYS_ARGS) -j $(NPROC)

yosys: yosys/libs  ## build yosys

yosys/install: yosys/libs  ## build and install yosys
	cd yosys && sudo make $(YOSYS_ARGS) PREFIX=$(or $(INSTALL_PREFIX),"/usr/local") install

yosys/debian:  ## build debian package for yosys
	mkdir -p yosys/debian/DEBIAN
	printf "Package: yosys\nVersion: $(YOSYS_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: yosys\n" > yosys/debian/DEBIAN/control
	$(MAKE) yosys/libs
	$(MAKE) yosys/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build yosys/debian yosys_$(YOSYS_VERSION)_amd64.deb


#                  _ _
#                 | (_)
#  ___ _   _ _ __ | |_  __ _
# / __| | | | '_ \| | |/ _` |
# \__ \ |_| | | | | | | (_| |
# |___/\__, |_| |_|_|_|\__, |
#       __/ |           __/ |
#      |___/           |___/
# 
# https://github.com/chipsalliance/synlig
#
.PHONY: synlig/libs synlig synlig/install synlig/debian

synlig/.git:
	# TODO once merged
	# git clone --depth 1 --branch $(SYNLIG_VERSION) https://github.com/chipsalliance/synlig.git
	git clone --depth 1 --branch tkp/newyosys https://github.com/timkpaine/synlig.git

synlig/libs: synlig/.git
	cd synlig/frontends/systemverilog && make -j $(NPROC)

synlig: synlig/libs  ## build synlig

synlig/install: yosys/libs  ## build and install synlig
	cd synlig/frontends/systemverilog && sudo make PREFIX=$(or $(INSTALL_PREFIX),"/usr/local") install

synlig/debian:  ## build debian package for synlig
	mkdir -p synlig/debian/DEBIAN
	printf "Package: synlig\nVersion: $(SYNLIG_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: synlig\n" > synlig/debian/DEBIAN/control
	$(MAKE) synlig/libs
	$(MAKE) synlig/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build synlig/debian synlig_$(SYNLIG_VERSION)_amd64.deb



#####################################################################################################################################################################################################################################################################################
# __      __       _ _       _
# \ \    / /      (_) |     | |
#  \ \  / /__ _ __ _| | __ _| |_ ___  _ __
#   \ \/ / _ \ '__| | |/ _` | __/ _ \| '__|
#    \  /  __/ |  | | | (_| | || (_) | |
#     \/ \___|_|  |_|_|\__,_|\__\___/|_|
#                                          
#
# https://github.com/verilator/verilator
#
.PHONY: verilator/build_static verilator verilator/install verilator/debian

verilator/.git:
	git clone --depth 1 --branch v$(VERILATOR_VERSION) https://github.com/verilator/verilator.git

verilator/build_static: verilator/.git
	cd verilator && cmake $(CMAKE_COMMON_ARGS_STATIC) .
	cd verilator && cmake $(CMAKE_BUILD_ARGS_STATIC)

verilator: verilator/build_static  ## build verilator

verilator/install: verilator/build_static  ## build and install verilator
	cd verilator && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)

verilator/debian:  ## build debian package for verilator
	mkdir -p verilator/debian/DEBIAN
	printf "Package: verilator\nVersion: $(VERILATOR_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: verilator\n" > verilator/debian/DEBIAN/control
	$(MAKE) verilator/build_static INSTALL_PREFIX=./debian
	$(MAKE) verilator/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build verilator/debian verilator_$(VERILATOR_VERSION)_amd64.deb




#####################################################################################################################################################################################################################################################################################
#      _                _
#     (_)              (_)
#  ___ _ _ __ _____   ___  _____      __
# / __| | '_ ` _ \ \ / / |/ _ \ \ /\ / /
# \__ \ | | | | | \ V /| |  __/\ V  V /
# |___/_|_| |_| |_|\_/ |_|\___| \_/\_/
#
# https://github.com/pieter3d/simview
#
.PHONY: simview/build_static simview simview/install simview/debian

ifeq ($(UNAME), Linux)
SIMVIEW_OUTPUT := $(or $(INSTALL_PREFIX),"/usr/local")/bin/
else ifeq ($(UNAME), Darwin)
SIMVIEW_OUTPUT := $(or $(INSTALL_PREFIX),"/opt/homebrew")/bin/
endif

simview/.git:
	git clone --depth 1 --branch tkp/mac_and_sharedlibs https://github.com/timkpaine/simview.git

simview/build_static: simview/.git
	cd simview && cmake $(CMAKE_COMMON_ARGS_STATIC) .
	cd simview && cmake $(CMAKE_BUILD_ARGS_STATIC)

simview: simview/build_static  ## build simview

simview/install: simview/build_static  ## build and install simview
	cd simview && sudo cmake $(CMAKE_INSTALL_ARGS_STATIC)
	cd simview && mkdir -p $(SIMVIEW_OUTPUT) && sudo cp build_static/simview $(SIMVIEW_OUTPUT)

simview/debian:  ## build debian package for simview
	mkdir -p simview/debian/DEBIAN
	printf "Package: simview\nVersion: $(SIMVIEW_VERSION)\nSection: utils\nPriority: optional\nArchitecture: amd64\nMaintainer: timkpaine <t.paine154@gmail.com>\nDescription: simview\n" > simview/debian/DEBIAN/control
	$(MAKE) simview/build_static INSTALL_PREFIX=./debian
	$(MAKE) simview/install INSTALL_PREFIX=./debian
	dpkg-deb -Z"gzip" --root-owner-group --build simview/debian simview_$(SIMVIEW_VERSION)_amd64.deb




#####################################################################################################################################################################################################################################################################################
#   _____ _      ______          _   _
#  / ____| |    |  ____|   /\   | \ | |
# | |    | |    | |__     /  \  |  \| |
# | |    | |    |  __|   / /\ \ | . ` |
# | |____| |____| |____ / ____ \| |\  |
#  \_____|______|______/_/    \_\_| \_|
#
.PHONY: clean
clean:  ## Delete all built repos
	sudo rm -rf googletest
	sudo rm -rf capnproto
	sudo rm -rf json
	sudo rm -rf antlr4
	sudo rm -rf uhdm
	sudo rm -rf surelog


.DEFAULT_GOAL := help
.PHONY: help
help:
	@grep -E '^[a-zA-Z0-9//_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'



#####################################################################################################################################################################################################################################################################################
#   _______ _                 _        _
#  |__   __| |               | |      | |
#     | |  | |__   __ _ _ __ | | _____| |
#     | |  | '_ \ / _` | '_ \| |/ / __| |
#     | |  | | | | (_| | | | |   <\__ \_|
#     |_|  |_| |_|\__,_|_| |_|_|\_\___(_)
#
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# https://patorjk.com/software/taag/#p=display&f=Big&t=Type%20Something%20
#
