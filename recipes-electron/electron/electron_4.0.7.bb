SUMMARY = "Build cross platform desktop apps with web technologies"
DESCRIPTION = "The Electron framework lets you write cross-platform \
desktop applications using JavaScript, HTML and CSS. It is based on \
io.js and Chromium and is used in the Atom editor."
HOMEPAGE = "https://electronjs.org/"

LIC_FILES_CHKSUM = "file://LICENSE;md5=18ae84aa915a8568a4c064a2bed03211"

LICENSE = "MIT"

RDEPENDS_${PN} = "nodejs"

SRC_URI = "https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz"

SRC_URI[md5sum] = "b8b44787c172a4b9a5862b4828955ce4"
SRC_URI[sha256sum] = "364f9f30b2bdf033ef5ea64c2e0eb7d1887f3c613d0399827a273c96d7c66716"

# Make recipe MACHINE specific
PACKAGE_ARCH = "${MACHINE_ARCH}"

INSANE_SKIP_${PN} += "file-rdeps"

inherit npm-install-global

BBCLASSEXTEND = "native nativesdk"
