# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM quay.io/fedora/fedora-bootc:latest

# Add files
COPY --chmod=0644 ./systemd/* /etc/systemd/system/

### MODIFICATIONS

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/00-repos.sh && \
    /ctx/helper/clean.sh && \
    ostree container commit

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/01-packages.sh && \
    /ctx/helper/clean.sh && \
    ostree container commit
    
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/02-systemd.sh && \
    /ctx/helper/clean.sh && \
    ostree container commit

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/03-sanitize.sh && \
    /ctx/helper/clean.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint