FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false
ENV PYTHONUNBUFFERED=1

# Allow yarn install even if Node engine versions do not match
RUN yarn config set ignore-engines true

# Create temporary Frappe config for build/runtime

RUN mkdir -p sites && \
    printf '{"db_host":"mariadb","db_port":3306,"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000,"webserver_port":8000}\n' > sites/common_site_config.json && \
    chown -R frappe:frappe sites

USER frappe

# Set yarn config again for frappe user
RUN yarn config set ignore-engines true

# Download Marley and its dependency apps, including Healthcare
RUN bench get-app --resolve-deps --skip-assets https://github.com/earthians/marley.git

# Build Healthcare assets only
RUN bench build --app healthcare

# Do NOT build Marley assets because it previously failed
# RUN bench build --app marley

EXPOSE 8000

# Use bench serve. Do not use system python.
CMD ["bash", "-lc", "cd /home/frappe/frappe-bench && bench serve --port 8000 --noreload"]
