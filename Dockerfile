FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false
ENV PYTHONUNBUFFERED=1

# Allow yarn install even if Node engine versions do not match
RUN yarn config set ignore-engines true

# Create temporary Frappe site config for build/runtime
# IMPORTANT:
# Redis hostname "redis" only works if your Coolify service/stack has Redis reachable as "redis"
RUN mkdir -p sites && \
    printf '{"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000,"webserver_port":8000}\n' > sites/common_site_config.json && \
    printf 'frontend\n' > sites/currentsite.txt && \
    chown -R frappe:frappe sites

# Create a simple Procfile so bench start does not fail
# Earlier runtime error happened because Procfile was missing
RUN printf 'web: bench serve --port 8000 --noreload\n' > Procfile && \
    chown frappe:frappe Procfile

USER frappe

# Set yarn config again for frappe user
RUN yarn config set ignore-engines true

# Download Marley and its dependency apps, including Healthcare
# --skip-assets prevents automatic build during get-app
RUN bench get-app --resolve-deps --skip-assets https://github.com/earthians/marley.git

# Build Healthcare assets only
RUN bench build --app healthcare

# Do NOT build Marley assets
# It previously failed with:
# TypeError [ERR_INVALID_ARG_TYPE]: The "path" argument must be of type string. Received undefined
# RUN bench build --app marley

EXPOSE 8000

CMD ["bash", "-lc", "cd /home/frappe/frappe-bench && bench start"]
