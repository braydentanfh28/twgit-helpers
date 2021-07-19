#!/bin/bash

GRAY='\033[1;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

PATCHPREFIX="patch-"


function twgit_patch_new() {
	local patchVersion=$1

	if [[ -z $patchVersion ]]; then
		echo -e
		echo -e "⚠️  ${YELLOW}Please provide target patch version.${NC}"
		echo -e
		return
	fi

	# ENSURE ALL CURRENT BRANCH CHANGES COMMITED
	if [ -n "$(git status --porcelain)" ]; then
		echo -e
		echo -e "⚠️  ${YELLOW}Untracked file present!${NC}"
		echo -e
		eval "git status -s"
		echo -e
		return
	fi

	# FETCH ORIGIN TAGS
	fecthOriginaCmd="git fetch -t -v origin"
	echo -e "${GRAY}\$ ${fecthOriginaCmd}${NC}"
	echo -e
	eval $fecthOriginaCmd

	# ENSURE TAGS IS PREFIXED
	if [[ $patchVersion =~ ^[^v.*] ]]; then
		echo -e "⚠️  ${YELLOW}Missing prefix for provided tags, appending 'v' as prefix...${NC}"
		echo -e
		patchVersion="v${patchVersion}"
	fi

	# ENSURE TAGS TO PATCH EXIST
	if git show-ref --tags $patchVersion --quiet; then
		# NO ACTION REQUIRED
		:
	else
		echo -e "‼️  ${RED}Provided tag(${patchVersion}) doesn't exists, please provide a valid tag to patch.${NC}"
		echo -e
		return
	fi

	# GET POST PATCH TAG
	curMajorNo=$(echo $patchVersion | cut -d. -f1)
	curMinorNo=$(echo $patchVersion | cut -d. -f2)
	curPatchNo=$(echo $patchVersion | cut -d. -f3)
	nextPatchNo=$((curPatchNo + 1))
	newTagToBe="${curMajorNo}.${curMinorNo}.${nextPatchNo}"

	if git show-ref --tags $newTagToBe --quiet; then
		echo -e "‼️  ${RED}New tag(${newTagToBe}) is already exists.${NC}"
		echo -e
		return
	fi

	# CREATE GIT BRANCH
	patchBranchName="${PATCHPREFIX}${newTagToBe}"
	createPatchBranchCmd="git checkout -b ${patchBranchName} ${patchVersion}"
	echo -e "${GRAY}\$ ${createPatchBranchCmd}${NC}"
	echo -e
	eval $createPatchBranchCmd

	switchBranchCmd="git checkout ${patchBranchName}"
	echo -e "${GRAY}\$ ${switchBranchCmd}${NC}"
	echo -e
	eval $switchBranchCmd
}