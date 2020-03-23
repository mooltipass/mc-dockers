#!/bin/bash

set -e

VERSION=$1
UPFILE=$2

if [ -z $VERSION ]
then
    echo "No version defined."
    echo "Usage:"
    echo "  upload.sh 1.2.3 file.xxx"
    echo "where file.xxx is in the shared volume of the docker"
    exit 1
fi

if [ -z $UPFILE ]
then
    echo "No file defined."
    echo "Usage:"
    echo "  upload.sh 1.2.3 file.xxx"
    echo "where file.xxx is in the shared volume of the docker"
    exit 1
fi

USER_EMAIL="limpkin@limpkin.fr"
GITHUB_REPO="minible"
GITHUB_ACCOUNT="mooltipass"

# Upload a release asset specifying a MIME type
#
# Note, this command requires `jq` to find the release `upload_url`.
#
# Usage:
#
#     upload_asset username reponame 1087938 \
#         foo.tar application/x-tar < foo.tar
#
# * (stdin)
#   The contents of the file to upload.
#
# Positional arguments
#
function upload_asset_mime()
{
    local owner="${1:?Owner name required.}"
    #   A GitHub user or organization.
    local repo="${2:?Repo name required.}"
    #   A GitHub repository.
    local release_id="${3:?Release ID required.}"
    #   The unique ID of the release; see list_releases.
    local name="${4:?File name is required.}"
    #   The file name of the asset.
    local mime="${5:?MIME type is required.}"
    #
    # Keyword arguments
    #
    local _filter='"\(.state)\t\(.browser_download_url)"'
    #   A jq filter to apply to the return data.
    shift 5
    ok.sh _opts_filter "$@"
    local upload_url=$(ok.sh release "$owner" "$repo" "$release_id" _filter="(.upload_url)" | sed -e 's/{?name,label}/?name='"$name"'/g')
    : "${upload_url:?Upload URL could not be retrieved.}"
    ok.sh _post "$upload_url" filename="$name" mime_type="$mime" > /dev/null
}

# Get a release ID specifying its name
#
# Usage:
#
#     get_release_id_by_name username reponame
#
# Positional arguments
#
function get_release_id_by_name()
{
    local NAME="${1:?Release name required.}"

    ok.sh list_releases "$GITHUB_ACCOUNT" "$GITHUB_REPO" _filter='.[] | "\(.name)\t\(.id)"' | grep "$NAME[^-]" | awk '{ print $2 }'
}

# Get a release asset ID specifying its name
#
# Usage:
#
#     get_release_asset_id_by_name releaseid assetname
#
# Positional arguments
#
function get_release_asset_id_by_name()
{
    local RELEASE_ID="${1:?Release ID name required.}"
    local NAME="${2:?Release asset name required.}"

    ok.sh release_assets "$GITHUB_ACCOUNT" "$GITHUB_REPO" "$RELEASE_ID" _filter='.[] | "\(.name)\t\(.id)"' | grep "$NAME[^-]" | awk '{ print $2 }'
}

# Delete a release asset ID by its ID
#
# Usage:
#
#     delete_release_asset_by_id assetid
#
# Positional arguments
#
function delete_release_asset_by_id()
{
    local ASSET_ID="${1:?Asset ID required.}"
    local delete_url="/repos/${GITHUB_ACCOUNT}/${GITHUB_REPO}/releases/assets/${ASSET_ID}"

    ok.sh _delete "$delete_url"
}

# Create a release and upload a new assset to that release
#
# Usage:
#
#     create_release_and_upload_asset reponame filepath
#
# Positional arguments
#
function create_release_and_upload_asset()
{
    local TAG=$1
    local FILE_PATH=$2

    if [ ! -f "$FILE_PATH" ]; then
       echo "The file $FILE_PATH does not exist so it can't be uploaded"
       return 0
    fi

    local MIME_TYPE=$(file --mime-type $FILE_PATH)
    local FILE_NAME=$(basename $FILE_PATH)
    local FILE_DIR=$(dirname $FILE_PATH)

    RELEASE_ID=$(get_release_id_by_name "$TAG")

    if [ -z "$RELEASE_ID" ]; then
        echo "Release for tag $TAG doesn't exist. Creating one..."
        RELEASE_ID=$(ok.sh create_release "$GITHUB_ACCOUNT" "$GITHUB_REPO" "$TAG" name="$TAG" | awk '{print $2}')
    else
        echo "Release for tag $TAG already exists. Using it."
    fi

    echo "Release ID: [${RELEASE_ID}]"

    ASSET_ID=$(get_release_asset_id_by_name "$RELEASE_ID" "$FILE_NAME")

    if [ -z "$ASSET_ID" ]; then
        echo "Asset not yet existing for release $TAG. Creating one..."
    else
        echo "Asset already existing in release $TAG. Removing it and preparing for a fresh upload."

        delete_release_asset_by_id "$ASSET_ID"
    fi

    echo "Uploading new asset $FILE_NAME to release ID $RELEASE_ID..."

    # We need to be in the directory or ok.sh goes crazy - seems it can't properly handle a file :(
    pushd $FILE_DIR > /dev/null
    upload_asset_mime "$GITHUB_ACCOUNT" "$GITHUB_REPO" "$RELEASE_ID" "$FILE_NAME" "$MIME_TYPE" < ${FILE_NAME}
    popd > /dev/null
}

function beginsWith()
{
    case $2 in "$1"*) true;; *) false;; esac;
}

function endsWith()
{
    case $2 in *"$1") true;; *) false;; esac;
}

cd /uploads

#Check if this is a test release or not
if endsWith -testing "$VERSION"
then
    create_release_and_upload_asset $VERSION $UPFILE
else
    create_release_and_upload_asset $VERSION $UPFILE
fi

