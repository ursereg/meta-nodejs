DEPENDS += " node-native"

inherit nodejs-arch

PACKAGE_DEBUG_SPLIT_STYLE = "debug-file-directory"

CCACHE = ""

NPM_REGISTRY ?= "https://registry.npmjs.org/"

NPM_IGNORE = "${WORKDIR}/.npmignore"

NPM ?= "npm"
NPM_HOME_DIR = "${TMPDIR}/npm_home/${PF}"
NPM_ARCH ?= "${@nodejs_map_dest_cpu(d.getVar('TARGET_ARCH', True), d)}"
NPM_LD ?= "${CXX}"
NPM_FLAGS ?= ""

NPM_FLAGS_append_class-nativesdk = " --unsafe-perm"

# Target npm

oe_runnpm() {

	if [ "${NPM_ARCH}" != "allarch" ]; then
		ARCH_FLAGS="--arch=${NPM_ARCH} --target_arch=${NPM_ARCH}"
	else
		ARCH_FLAGS=""
	fi

	echo "/temp/" >> "${NPM_IGNORE}"
	echo "/pseudo/" >> "${NPM_IGNORE}"
	echo "/sstate*/" >> "${NPM_IGNORE}"
	echo "/license-destdir/" >> "${NPM_IGNORE}"
	echo "/image/" >> "${NPM_IGNORE}"
	echo "/patches/" >> "${NPM_IGNORE}"
	echo ".npmignore" >> "${NPM_IGNORE}"
	echo "/.*/" >> "${NPM_IGNORE}"

	mkdir -p "${NPM_HOME_DIR}"

	if [ "${NPM_CACHE_DIR}" = "" ]; then
		NPM_VERSION=`${NPM} -v`
		export NPM_CONFIG_CACHE="${DL_DIR}/npm_v${NPM_VERSION}_${TARGET_ARCH}_cache/${PF}"
	else
		export NPM_CONFIG_CACHE=${NPM_CACHE_DIR}
	fi

	export NPM_CONFIG_DEV="false"
	NPM_VERSION=$(${NPM} -v)

	bbnote NPM target architecture: ${NPM_ARCH}
	bbnote NPM home directory: ${NPM_HOME_DIR}
	bbnote NPM cache directory: ${NPM_CONFIG_CACHE}
	bbnote NPM registry: ${NPM_REGISTRY}
	bbnote NPM workdir .npmignore: ${NPM_IGNORE}

	bbnote ${NPM} --registry=${NPM_REGISTRY} ${ARCH_FLAGS} ${NPM_FLAGS} "$@"

	export JOBS=${@oe.utils.cpu_count()}

	export http_proxy="${http_proxy}"
	export https_proxy="${https_proxy}"
	export no_proxy="${no_proxy}"

	export HOME="${NPM_HOME_DIR}"

	bbnote NPM version: ${NPM_VERSION}

	NPM_VERSION_MAJOR=`echo $NPM_VERSION | cut -d. -f1`
	if [ ${NPM_VERSION_MAJOR} -ge 5 ]; then
		${NPM} cache verify || die "oe_runnpm failed (cache verify)"
	else
		${NPM} cache clean || die "oe_runnpm failed (cache clean)"
	fi

	LD="${NPM_LD}" ${NPM} --registry=${NPM_REGISTRY} ${ARCH_FLAGS} ${NPM_FLAGS} "$@" || die "oe_runnpm failed (install)"

}

# Native npm

NPM_NATIVE ?= "npm"
NPM_HOME_DIR_NATIVE = "${TMPDIR}/npm_home_native/${PF}"
NPM_ARCH_NATIVE ?= "${@nodejs_map_dest_cpu(d.getVar('BUILD_ARCH', True), d)}"
NPM_LD_NATIVE ?= "${BUILD_CXX}"
NPM_FLAGS_NATIVE ?= ""

NPM_FLAGS_NATIVE_append_class-nativesdk = " --unsafe-perm"

oe_runnpm_native() {

	if [ "${NPM_ARCH_NATIVE}" != "allarch" ]; then
		ARCH_FLAGS="--arch=${NPM_ARCH_NATIVE} --target_arch=${NPM_ARCH_NATIVE}"
	else
		ARCH_FLAGS=""
	fi

	echo "/temp/" >> "${NPM_IGNORE}"
	echo "/pseudo/" >> "${NPM_IGNORE}"
	echo "/sstate*/" >> "${NPM_IGNORE}"
	echo "/license-destdir/" >> "${NPM_IGNORE}"
	echo "/image/" >> "${NPM_IGNORE}"
	echo "/patches/" >> "${NPM_IGNORE}"
	echo ".npmignore" >> "${NPM_IGNORE}"
	echo "/.*/" >> "${NPM_IGNORE}"

	mkdir -p "${NPM_HOME_DIR_NATIVE}"

	if [ "${NPM_CACHE_DIR_NATIVE}" = "" ]; then
		NPM_VERSION=`${NPM} -v`
		export NPM_CONFIG_CACHE="${DL_DIR}/npm_v${NPM_VERSION}_${TARGET_ARCH}_native/${PF}"
	else
		export NPM_CONFIG_CACHE=${NPM_CACHE_DIR_NATIVE}
	fi

	export NPM_CONFIG_DEV="false"
	NPM_VERSION=$(${NPM} -v)

	bbnote NPM native architecture: ${NPM_ARCH_NATIVE}
	bbnote NPM home directory: ${NPM_HOME_DIR_NATIVE}
	bbnote NPM cache directory: ${NPM_CONFIG_CACHE}
	bbnote NPM registry: ${NPM_REGISTRY}
	bbnote NPM workdir .npmignore: ${NPM_IGNORE}

	bbnote ${NPM_NATIVE} --registry=${NPM_REGISTRY} ${ARCH_FLAGS} ${NPM_FLAGS_NATIVE} "$@"

	export JOBS=${@oe.utils.cpu_count()}

	export http_proxy="${http_proxy}"
	export https_proxy="${https_proxy}"
	export no_proxy="${no_proxy}"

	export HOME="${NPM_HOME_DIR_NATIVE}"

	NPM_VERSION_MAJOR=`echo $NPM_VERSION | cut -d. -f1`
	if [ ${NPM_VERSION_MAJOR} -ge 5 ]; then
		${NPM} cache verify || die "oe_runnpm failed (cache verify)"
	else
		${NPM} cache clean || die "oe_runnpm failed (cache clean)"
	fi

	LD="${NPM_LD_NATIVE}" ${NPM_NATIVE} --registry=${NPM_REGISTRY} ${ARCH_FLAGS} ${NPM_FLAGS_NATIVE} "$@" || die "oe_runnpm_native failed (install)"

}
