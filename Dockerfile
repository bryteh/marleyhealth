FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

# Force Yarn to ignore Node engine mismatch globally
ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false

# Set yarn config for root user
RUN yarn config set ignore-engines true

# Create temporary Frappe config for Docker build stage
# This fixes Redis URL error during bench build
RUN mkdir -p sites && \
    printf '{"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000}\n' > sites/common_site_config.json && \
    chown -R frappe:frappe sites

USER frappe

# Set yarn config again for frappe user
RUN yarn config set ignore-engines true

# Download Marley and its dependency apps, including Healthcare
# --skip-assets prevents automatic build during get-app
RUN bench get-app --resolve-deps --skip-assets https://github.com/earthians/marley.git

# Build Healthcare assets only
RUN bench build --app healthcare

# Do NOT build Marley assets because it causes undefined asset path error
# RUN bench build --app marley
