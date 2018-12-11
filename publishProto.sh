#!/usr/bin/env bash
# This script generates the grpc clients for a set of services. Code based
# on the namely gist available at: https://gist.githubusercontent.com/bobbytables/2fab9ac9509867b5acfe2bb5693aee71/raw/6f6d9cf27facd05fc88762ed7ab78cac7e72124d/build.sh

# Original description:
# This script is meant to build and compile every protocolbuffer for each
# service declared in this repository (as defined by sub-directories).
# It compiles using docker containers based on Namely's protoc image
# seen here: https://github.com/namely/docker-protoc

set -e

REPOPATH=${REPOPATH-/opt/protolangs}
echo "Repopath: ${REPOPATH}"
CURRENT_BRANCH=${CURRENT_BRANCH-"branch-not-available"}
echo "CurrentBranch: ${CURRENT_BRANCH}"

DRY_RUN=${DRY_RUN-"false"}

# Helper for adding a directory to the stack and echoing the result
function enterDir {
  echo "Entering $1"
  pushd $1 > /dev/null
}

# Helper for popping a directory off the stack and echoing the result
function leaveDir {
  echo "Leaving `pwd`"
  popd > /dev/null
}

# Enters the directory and starts the build / compile process for the services
# protobufs
function buildDir {
  currentDir="$1"
  echo "Building directory \"$currentDir\""

  enterDir $currentDir

  buildProtoForTypes $currentDir

  leaveDir
}

# Iterates through all of the languages listed in the services .protolangs file
# and compiles them individually
function buildProtoForTypes {
  target=${1%/}

  if [ -f .protolangs ]; then
    while read lang; do
      reponame="grpc-$target-$lang"
      echo "Building $reponame"
      rm -rf $REPOPATH/$reponame

      echo "Cloning repo: git@github.com:nalej/$reponame.git"

      # Clone the repository down and set the branch to the automated one
      git clone git@github.com:nalej/$reponame.git $REPOPATH/$reponame
      setupBranch $REPOPATH/$reponame

      # Use the docker container for the language we care about and compile
      # TODO Check for the language to run this only for go
      docker run -v ${REPOPATH}:/defs namely/protoc-all:1.15 -d ${target} -i . -i /usr/local/include/google -o ${target}/pb-$lang -l $lang --with-docs --with-gateway
      # Copy the generated files out of the pb-* path into the repository
      # that we care about
      cp -R pb-$lang/github.com/nalej/grpc-${target}-${lang}/* $REPOPATH/$reponame/
      cp -R pb-$lang/doc $REPOPATH/$reponame/
      cp -R pb-$lang/${target}/*.swagger.json $REPOPATH/$reponame/doc/.

      ls $REPOPATH/$reponame
      if [ "${DRY_RUN}" == "true" ]; then
          echo "Commit and push has been omitted"
      else
          commitAndPush $REPOPATH/$reponame
      fi


    done < .protolangs
  fi
}

# Finds all directories in the repository and iterates through them calling the
# compile process for each one
function buildAll {
  echo "Building service's protocol buffers"
  mkdir -p $REPOPATH
  for d in */; do
    buildDir $d
  done
}

function buildSingle {
    echo "Building single service"
    mkdir -p $REPOPATH
    buildDir $1
}

function setupBranch {
  enterDir $1

  echo "Creating branch"

  if ! git show-branch $CURRENT_BRANCH; then
    git branch $CURRENT_BRANCH
  fi

  git checkout $CURRENT_BRANCH

  if git ls-remote --heads --exit-code origin $CURRENT_BRANCH; then
    echo "Branch exists on remote, pulling latest changes"
    git pull origin $CURRENT_BRANCH
  fi

  leaveDir
}

function commitAndPush {
  enterDir $1

  git add -N .

  if ! git diff --exit-code > /dev/null; then
    if [ ! -f VERSION ]; then
        echo "Creating initial version"
        echo "0.0.0" > VERSION
    fi
    CURRENT_VERSION_STRING=`cat VERSION`
    VERSION_VALUES=(`echo $CURRENT_VERSION_STRING | tr '.' ' '`)
    V_MAJOR=${VERSION_VALUES[0]}
    V_MINOR=${VERSION_VALUES[1]}
    V_PATCH=${VERSION_VALUES[2]}
    V_PATCH=$((V_PATCH + 1))
    NEW_VERSION="${V_MAJOR}.${V_MINOR}.${V_PATCH}"
    echo "New version will be ${NEW_VERSION}"
    echo $NEW_VERSION > VERSION
    git add .
    git commit -m "Auto generated gRPC"
    git push origin HEAD
    git tag -a -m "Auto generated version ${NEW_VERSION}." "v$NEW_VERSION"
    git push origin --tags
  else
    echo "No changes detected for $1"
  fi

  leaveDir
}

TARGET_SERVICE=$1

if [[ "${TARGET_SERVICE}" == "" ]]; then
    buildAll
else
    buildSingle ${TARGET_SERVICE}
fi

