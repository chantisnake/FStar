#!/usr/bin/env bash

# Sorry, everyone
if (( ${BASH_VERSION%%.*} < 4 )); then
  echo "This script requires Bash >= 4. On OSX, try: brew install bash"
  exit 1
fi

# Any error is fatal.
set -e
set -o pipefail

BUILD_DIR=$(pwd)
if [[ -f ~/.bash_profile ]]; then
echo "+++ Run source .bash_profile ++"
  source ~/.bash_profile
fi
cd "$BUILD_DIR"

# Constants for showing color in output window
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

CURRENT_VERSION=$(head -n 1 version.txt)

echo "** Clean up log files **"
if [[ -f src/ocaml-output/fstar/MicroBenchMarkOutput.log ]]; then
  echo "-- Delete MicroBenchMark Log --"
  rm src/ocaml-output/fstar/MicroBenchMarkOutput.log
fi
if [[ -f src/ocaml-output/fstar/HelloOcamlOutput.log ]]; then
  echo "-- Delete Hello Ocaml Log --"
  rm src/ocaml-output/fstar/HelloOcamlOutput.log
fi
if [[ -f src/ocaml-output/fstar/HelloFStarOutput.log ]]; then
  echo "-- Delete Hello Fstar Log --"
  rm src/ocaml-output/fstar/HelloFStarOutput.log
fi
if [[ -f src/ocaml-output/fstar/AllExamples.log ]]; then
  echo "-- Delete All Examples Log --"
  rm src/ocaml-output/fstar/AllExamples.log
fi

echo "*** Make package ***"
cd src
cd ocaml-output
make package

# For weekly build, we want to use TimeStamp since it is a minor release
echo "*** Unzip and verify the Package  ***"
TIME_STAMP=$(date +%s)
echo "+++ Time Stamp:"$TIME_STAMP
echo "+++ Current Version:"$CURRENT_VERSION

# make package makes it major version using version.txt. This process is weekly process to make minor versions (using timestamp in file name) 
TYPE="_Windows_x64.zip"
MAJOR_ZIP_FILE=fstar_$CURRENT_VERSION$TYPE
echo "+++ Major Zip file:"$MAJOR_ZIP_FILE
if [[ -f $MAJOR_ZIP_FILE ]]; then
  MINOR_ZIP_FILE=fstar_$TIME_STAMP$TYPE
echo "----- Copy Original Minor Zip File ---"
echo "+++ " $MAJOR_ZIP_FILE $MINOR_ZIP_FILE  
  cp $MAJOR_ZIP_FILE $MINOR_ZIP_FILE
echo "----- Unzip Zip File:"$MAJOR_ZIP_FILE  
  unzip -o $MAJOR_ZIP_FILE
fi

# Extract linux file if exists
TYPE="_Linux_x86_64.tar.gz"  
MAJOR_TAR_FILE=fstar_$CURRENT_VERSION$TYPE
echo "+++ Major tar File:"$MAJOR_TAR_FILE
if [[ -f $MAJOR_TAR_FILE ]]; then
  MINOR_TAR_FILE=fstar_$TIME_STAMP$TYPE
echo "----- Copy Original Minor Tar File ---"
echo "+++ "$MAJOR_TAR_FILE $MINOR_TAR_FILE
  cp $MAJOR_TAR_FILE $MINOR_TAR_FILE
echo "----- Extract Tar File:"$MAJOR_TAR_FILE
  tar -x -f $MAJOR_TAR_FILE
fi

echo "*** Make the examples ***"
cd fstar
make -C examples/micro-benchmarks 1> MicroBenchMarkOutput.log
make -C examples/hello ocaml 1> HelloOcamlOutput.log
make -C examples/hello fs 1> HelloFStarOutput.log
make -j6 -C examples 1> AllExamples.log

echo "*** Verify the examples ***"
echo "* Verify Micro-benchmarks -- should output 'Success:' *"
if ! egrep 'Success:' MicroBenchMarkOutput.log; then
  echo -e "* ${RED}FAIL!${NC} for examples/micro-benchmarks - Success: was not found in MicroBenchMarkOutput.log"
#  exit 1  # want to exit because don't want to continue and copy build out but for testing purposes comment out
else
  echo -e "* ${GREEN}PASSED!${NC} for examples/micro-benchmarks"
fi

echo "* Verify hello ocaml -- should output Hello F*! *"
if ! egrep 'F*!' HelloFStarOutput.log; then
  echo -e "* ${RED}FAIL!${NC} for examples/hello ocaml - F*! was not found in HelloOcamlOutput.log"
#  exit 1  # want to exit because don't want to continue and copy build out but for testing purposes comment out
else
  echo -e "* ${GREEN}PASSED!${NC} for examples/hello ocaml"
fi

echo "* Verify hello fs -- should output Hello F*!"
if ! egrep 'F*!' HelloFStarOutput.log; then
  echo -e "* ${RED}FAIL!${NC} for examples/hello fs - F*! was not found in HelloFStarOutput.log"
#  exit 1  # want to exit because don't want to continue and copy build out but for testing purposes comment out
else
  echo -e "* ${GREEN}PASSED!${NC} for examples/hello fs"
fi

echo "* Verify all examples -- Look for Success:"
if ! egrep 'Success:' AllExamples.log; then
  echo -e "* ${RED}FAIL!${NC} for all examples - Success: was not found in AllExamples.log"
#  exit 1  # want to exit because don't want to continue and copy build out but for testing purposes comment out
else
  echo -e "* ${GREEN}PASSED!${NC} for all examples"
fi

# Got to this point, so know it passed - copy minor version out to see if it works
echo "* Upload the minor version of the package. Will only keep the most recent 4 packages"
cd ../../..
ORIG_PWD=$PWD
echo "+++ ORIG PWD:"$ORIG_PWD
BN_BINARYSPATH_ROOT=~/binaries
BN_BINARYSPATH=$BN_BINARYSPATH_ROOT/weekly   # maybe this should be environment var or something like that similar to CI_LOGS
FSTAR_BIN_BRANCH="master"
BN_FILESTOKEEP=4

# check that BN_BINARYSPATH_ROOT exists.
if [[ ! -d $BN_BINARYSPATH_ROOT ]]; then
  echo "+++ " $BN_BINARYSPATH_ROOT " does not exist so cloning"
  git clone https://github.com/FStarLang/binaries.git
fi

cd $BN_BINARYSPATH_ROOT
echo "--git checkout --"
git checkout $FSTAR_BIN_BRANCH
echo "--git pull --"
git pull origin master # maybe need --allow-unrelated-histories  # git 2.9 and above

echo "-- copy files --"
if [[ -f $ORIG_PWD/src/ocaml-output/$MINOR_ZIP_FILE ]]; then
  echo "+++ Copy Minor Zip File ***"
  echo "+++ "$ORIG_PWD/src/ocaml-output/$MINOR_ZIP_FILE $BN_BINARYSPATH
  cp $ORIG_PWD/src/ocaml-output/$MINOR_ZIP_FILE $BN_BINARYSPATH
 
  echo "+++ Git Add: "~/$BN_BINARYSPATH/$MINOR_ZIP_FILE
  git add $BN_BINARYSPATH/$MINOR_ZIP_FILE
fi
if [[ -f $ORIG_PWD/src/ocaml-output/$MINOR_TAR_FILE ]]; then
  echo "+++ Copy Minor Tar File ***"
  echo "+++" $ORIG_PWD/src/ocaml-output/$MINOR_TAR_FILE $BN_BINARYSPATH
  cp $ORIG_PWD/src/ocaml-output/$MINOR_TAR_FILE $BN_BINARYSPATH
  git add $BN_BINARYSPATH/$MINOR_TAR_FILE
fi

# Now that latest package is added, remove the oldest one so only keeping most recent 4 packages
echo "-- Delete oldest ZIP file --"
BN_ZIP_FILES=$BN_BINARYSPATH/*.zip
echo "++ Zip Files:"$BN_ZIP_FILES
ZIP_COUNT=`ls -1 $BN_ZIP_FILES 2>/dev/null | wc -l`
echo "+++ Zip Count:"$ZIP_COUNT
if [[ $ZIP_COUNT > $BN_FILESTOKEEP ]]; then
  echo "+++ Deleted oldest .zip file ---"
  ZIP_FILE_LIST=`ls -t1 $BN_ZIP_FILES | tail -n +$(($BN_FILESTOKEEP+1))` 
  for ZIP_FILE in $ZIP_FILE_LIST
  do
     echo "+++Delete Zip file:"${ZIP_FILE}
     rm ${ZIP_FILE}
     git rm ${ZIP_FILE}
  done
fi

echo "+++ Delete oldest TAR file --"
BN_TAR_FILES=$BN_BINARYSPATH/*.gz
echo "+++ Tar Files:"$BN_TAR_FILES
TAR_COUNT=`ls -1 $BN_TAR_FILES 2>/dev/null | wc -l`
echo "++ Tar Count:"$TAR_COUNT
if [[ $TAR_COUNT > $BN_FILESTOKEEP ]]; then
  echo "+++ Deleted oldest .gz file ---"
  ls -t1 $BN_TAR_FILES | tail -n +$(($BN_FILESTOKEEP+1)) | xargs rm
  TAR_FILE_LIST=`ls -t1 $BN_TAR_FILES | tail -n +$(($BN_FILESTOKEEP+1))` 
  for TAR_FILE in $TAR_FILE_LIST
  do
     echo "+++ Delete Tar file:"${TAR_FILE}
     rm ${TAR_FILE}
     git rm ${TAR_FILE}
  done
fi

echo "+++ Binary Path:"$BN_BINARYSPATH
echo "+++ PWD:"$PWD
# Commit and push - adding a new one and removing the oldest - commit with amend to keep history limited
echo "--- now commit it --- "
git commit --amend -m "Adding new build package and removing oldest."
echo "--- now push it --- "
git push git@github.com:FStarLang/binaries.git $FSTAR_BIN_BRANCH --force


# TO DO - new features to implement
# Handling BN_BINARYSPATH proper? Environment var maybe?
# slack notification on failure?

# TO DO - clean up debug code
# Uncomment the "exit" from the Verify section as if those fail we do not want to continue
# Clean up the debug echo messages

# Manual steps on major releases
# 1) Update https://github.com/FStarLang/FStar/blob/master/version.txt 
# 2) Create a new branch based on that version
# 3) Document the release

echo "**** DONE!!! ****"
