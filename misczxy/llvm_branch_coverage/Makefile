.PHONY: all
#asan msan ubsan 
all: branch_coverage
#	DOCKER_BUILDKIT=1 docker build --network=host -t crash_analysis .
#all: submodules framework docker tools

branch_coverage:
	DOCKER_BUILDKIT=1 docker build --network=host -t crash_analysis_branch_coverage -f Dockerfile.branch_coverage .		
