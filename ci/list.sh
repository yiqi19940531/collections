#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"
base_dir_name=$(basename $base_dir)

# check if running on travis pull request or not
if [ $TRAVIS_PULL_REQUEST ] && [ "$TRAVIS_PULL_REQUEST" != "false" ] || [ $TRAVIS_COMMIT_RANGE ]
then
    # check for changed files
    echo "Listing new/updated stacks in this pull request"
    CHANGED_FILES=$(git diff --name-only $TRAVIS_COMMIT_RANGE)

    for changed_stacks in $CHANGED_FILES
    do
        if [[ $changed_stacks == *stack.yaml ]]
        then
            var=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $changed_stacks`
            STACKS_LIST+=("$var")
        fi
    done
else
    if [ $TRAVIS_TAG ] && [ ! $BUILD_ALL ]
    then
        stack_id=`echo ${TRAVIS_TAG/-v[0-9]*/}`
        echo "Listing stacks for this release"
    else
        echo "Listing all stacks"
    fi

    repo_list="experimental incubator stable"
    for repo_name in $repo_list
    do
        repo_dir=$base_dir/$repo_name
        if [ -d $repo_dir ]
        then
            for stack_exists in $repo_dir/*/stack.yaml
            do
                if [ -f $stack_exists ]
                then
<<<<<<< Upstream, based on Appsody-stacks/master
                    var=`echo ${stack_exists#"$base_dir/"}`
=======
                    var=`echo $stack_exists | sed 's/.*'$base_dir_name'\///'`
>>>>>>> 7f5d51f Fixes to get collection build to work
                    repo_stack=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $var`
                    if [ $TRAVIS_TAG ] && [ ! $BUILD_ALL ] && [[ $repo_stack != */$stack_id ]]
                    then
                        continue;
                    fi
                    # list of repositories to build indexes for
                    STACKS_LIST+=("$repo_stack")
                fi
            done
        fi
    done
fi

# expose environment variable for stacks
export STACKS_LIST=${STACKS_LIST[@]}
echo "STACKS_LIST=$STACKS_LIST"
