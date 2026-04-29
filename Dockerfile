FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

# Allow yarn install even if package engine versions do not match
RUN yarn config set ignore-engines true

# Create temporary Frappe config for Docker build stage
# This fixes the Redis URL error during bench build
RUN mkdir -p sites && \
    printf '{"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000}\n' > sites/common_site_config.json && \
    chown -R frappe:frappe sites

USER frappe

# Download Marley and its dependency apps, including Healthcare
# --skip-assets prevents automatic build during get-app
RUN bench get-app --resolve-deps --skip-assets https://github.com/earthians/marley.git

# Build Healthcare assets only
RUN bench build --app healthcare

# Do NOT build Marley assets
# RUN bench build --app marley
