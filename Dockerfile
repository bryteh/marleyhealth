FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

# Allow yarn to continue even if some packages have engine mismatch
RUN yarn config set ignore-engines true

# Create basic Frappe site config for build stage
RUN mkdir -p sites && \
    echo '{"redis_cache": "redis://redis:6379", "redis_queue": "redis://redis:6379", "redis_socketio": "redis://redis:6379"}' > sites/common_site_config.json

# Switch back to frappe user
USER frappe

# Get Healthcare app
RUN bench get-app healthcare --branch version-14

# Build Healthcare assets
RUN bench build --app healthcare

# IMPORTANT:
# Do not run `bench build --app marley`
# Your Coolify deployment failed because marley asset build produced:
# TypeError [ERR_INVALID_ARG_TYPE]: The "path" argument must be of type string. Received undefined
# So we skip marley frontend asset build.
# RUN bench build --app marley
