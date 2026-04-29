FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false
ENV PYTHONUNBUFFERED=1

RUN yarn config set ignore-engines true

# Replace existing healthcare app with your forked version-14 code
RUN rm -rf apps/healthcare

COPY --chown=frappe:frappe . apps/healthcare

USER frappe

RUN yarn config set ignore-engines true

RUN /home/frappe/frappe-bench/env/bin/pip install -e apps/healthcare

RUN cd apps/healthcare && yarn install --check-files || true

RUN if [ -d "apps/healthcare/patient_portal" ]; then \
      cd apps/healthcare/patient_portal && yarn install --check-files || true; \
    fi

# Do not build healthcare assets during Docker build
# RUN bench build --app healthcare

USER root

EXPOSE 8000

CMD ["bash", "-lc", "cd /home/frappe/frappe-bench && \
mkdir -p sites && \
chown -R frappe:frappe sites && \
if [ ! -f sites/apps.txt ]; then printf 'frappe\\nerpnext\\nhealthcare\\n' > sites/apps.txt; fi && \
chown frappe:frappe sites/apps.txt && \
python - <<'PY'\nimport os, json\nconf = {\n  'db_host': os.environ.get('DB_HOST'),\n  'db_port': int(os.environ.get('DB_PORT', '3306')),\n  'redis_cache': os.environ.get('REDIS_CACHE'),\n  'redis_queue': os.environ.get('REDIS_QUEUE'),\n  'redis_socketio': os.environ.get('REDIS_SOCKETIO'),\n  'socketio_port': 9000,\n  'webserver_port': 8000\n}\nconf = {k:v for k,v in conf.items() if v is not None}\nwith open('sites/common_site_config.json', 'w') as f:\n    json.dump(conf, f)\nPY\nchown frappe:frappe sites/common_site_config.json && \
su frappe -c 'cd /home/frappe/frappe-bench && bench serve --host 0.0.0.0 --port 8000 --noreload'"]
