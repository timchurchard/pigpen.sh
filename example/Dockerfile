# Debian based Dockerfile to demo the pigpen.sh
FROM debian:bookworm

ENV MAIN_GROUP=notroot \
    MAIN_USER=notroot \
    MAIN_UID=10001

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -qq -y psmisc util-linux xxd sudo curl

RUN addgroup --gid "$MAIN_UID" "${MAIN_GROUP}" && \
    adduser \
    --disabled-password \
    --home "/nonexistent" \
    --no-create-home \
    --shell "/sbin/nologin" \
    --gid "${MAIN_UID}" \
    --uid "${MAIN_UID}" \
    "${MAIN_USER}"

RUN mkdir -p /opt/pigpen
RUN curl https://raw.githubusercontent.com/timchurchard/pigpen.sh/refs/tags/v0.1/pigpen.sh -o /opt/pigpen/pigpen.sh
RUN chmod +x /opt/pigpen/pigpen.sh

# Allow notroot user to run pigpen.sh with privileges (note: cannot use suid bit with #! script)
RUN echo "\n\
${MAIN_USER} ALL=(ALL) !ALL\n\
${MAIN_USER} ALL=NOPASSWD: /opt/pigpen/pigpen.sh\n\
" > /etc/sudoers.d/${MAIN_USER}

USER ${MAIN_USER}
CMD /bin/bash
