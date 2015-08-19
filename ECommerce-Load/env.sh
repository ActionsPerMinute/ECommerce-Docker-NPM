# 1st param to LoadRunner call
if [ -z "${NUM_OF_USERS}" ]; then
        export NUM_OF_USERS="5";
fi

# 3rd param to LoadRunner call
if [ -z "${TIME_BETWEEN_RUNS}" ]; then
        export TIME_BETWEEN_RUNS="5000";
fi

# 4th param to LoadRunner call
if [ -z "${TARGET_HOST}" ]; then
	export TARGET_HOST="web";
fi

# 6th param to LoadRunner call
if [ -z "${TARGET_PORT}" ]; then
        export TARGET_PORT="8080";
fi
