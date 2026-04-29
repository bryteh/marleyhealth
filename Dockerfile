FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false

RUN yarn config set ignore-engines true

RUN mkdir -p sites && \
    printf '{"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000,"webserver_port":8000}\n' > sites/common_site_config.json && \
    chown -R frappe:frappe sites

USER frappe

RUN yarn config set ignore-engines true

RUN bench get-app --resolve-deps --skip-assets https://github.com/earthians/marley.git

RUN bench build --app healthcare

EXPOSE 8000

CMD ["bench", "start"]
