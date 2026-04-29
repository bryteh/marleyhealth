FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false

# Allow yarn install even if Node engine versions do not match
RUN yarn config set ignore-engines true

# Temporary Frappe config for build/runtime
RUN mkdir -p sites && \
    printf '{"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000,"webserver_port":8000}\n' > sites/common_site_config.json && \
    chown -R frappe:frappe sites

USER frappe

# Set yarn config again for frappe user
RUN yarn config set ignore-engines true

# Download Marley and dependencies, including Healthcare
RUN bench get-app --resolve-deps --skip-assets https://github.com/earthians/marley.git

# Build Healthcare assets only
RUN bench build --app healthcare

EXPOSE 8000

# Use bench serve instead of bench start
# bench start requires Procfile, but this Docker image does not have one
CMD ["bench", "serve", "--port", "8000"]
