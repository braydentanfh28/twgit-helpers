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


function twgit_patch_finish() {
	local newPatchTag=$1

	if [[ -z $newPatchTag ]]; then
		echo -e
		echo -e "⚠️  ${YELLOW}Please provide target patch version to finish.${NC}"
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
	# eval $fecthOriginaCmd

	# ENSURE TAGS IS PREFIXED
	if [[ $newPatchTag =~ ^[^v.*] ]]; then
		echo -e "⚠️  ${YELLOW}Missing prefix for provided tags, appending 'v' as prefix...${NC}"
		echo -e
		newPatchTag="v${newPatchTag}"
	fi

	# ENSURE PATCH TO FINISH BRANCH EXIST
	patchBranchName="${PATCHPREFIX}${newPatchTag}"
	if git show-ref $patchBranchName --quiet; then
		# NO ACTION REQUIRED
		:
	else
		echo -e "‼️  ${RED}Target patch branch(${patchBranchName}) to finish is not available.${NC}"
		echo -e
		return
	fi

	# CREATE TAGS FROM BRANCH
	eval "git checkout ${patchBranchName}"
	eval "git tag ${newPatchTag}"
	eval "git push origin --tags"

	# REMOVE PATCH BRANCH
	eval "git checkout stable"
	eval "git branch -D ${patchBranchName}"
}