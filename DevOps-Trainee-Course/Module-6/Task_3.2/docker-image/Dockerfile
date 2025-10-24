FROM nginx:stable

ENV SECRET "default"

COPY ./default.conf.template /etc/nginx/templates/default.conf.template
COPY ./start.sh /start.sh

RUN chmod +x /start.sh

ENTRYPOINT [ "/start.sh" ]




