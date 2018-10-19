inherit npm-base

B="${S}"

NPM_INSTALL_FLAGS ?= ""

# Install the local dependencies and make the package ready for installation
do_configure() {
	oe_runnpm ${NPM_INSTALL_FLAGS} install --verbose
}

# Install the package globally
do_install() {
	NPM_VERSION=$(${NPM} -v)
	NPM_VERSION_MAJOR=`echo $NPM_VERSION | cut -d. -f1`
	if [ ${NPM_VERSION_MAJOR} -ge 5 ]; then
		oe_runnpm ${NPM_INSTALL_FLAGS} pack ${S}
		NODE_APP_VERSION=$(npm version | grep ${BPN} | cut -d: -f2 | sed -e "s/[\t ,']//g")
		oe_runnpm ${NPM_INSTALL_FLAGS} install -g --prefix=${D}${prefix} --verbose ${BPN}-${NODE_APP_VERSION}.tgz
		rm ${BPN}-${NODE_APP_VERSION}.tgz
	else
		oe_runnpm ${NPM_INSTALL_FLAGS} install -g --prefix=${D}${prefix} --verbose
	fi

}

FILES_${PN} += "${prefix}"

#
# npm causes unavoidable host-user-contaminated QA warnings for debug packages
#
INSANE_SKIP_${PN}-dbg += " host-user-contaminated"
