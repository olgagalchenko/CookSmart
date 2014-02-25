#!/bin/sh

set -x

CURRENT_GIT_TAG=$(git describe --abbrev=0 --tags)
COMMITS_SINCE_TAG=$(git rev-list $CURRENT_GIT_TAG..HEAD --count)
CURRENT_HASH=$(git rev-parse --short HEAD)
git update-index -q --refresh
test -z "$(git diff-index --name-only HEAD --)" ||
CURRENT_HASH="$CURRENT_HASH-dirty"

DESIRED_SHORT_BUNDLE_VERSION=${CURRENT_GIT_TAG}
DESIRED_BUNDLE_VERSION=${CURRENT_GIT_TAG}
if [ "${CONFIGURATION}" != "Release" ]; then
	DESIRED_BUNDLE_VERSION="${CURRENT_HASH}.${COMMITS_SINCE_TAG}"
fi

defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleShortVersionString" "${DESIRED_SHORT_BUNDLE_VERSION}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleVersion" "${DESIRED_BUNDLE_VERSION}"
