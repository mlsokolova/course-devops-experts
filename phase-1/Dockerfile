# -----------------------------------------------------------------------------
# Build stage — Debian 12 (Bookworm)
# Matches the Debian major version of the distroless runtime so the venv’s
# Python layout (symlinks under /usr/bin, libs under /usr/lib) resolves in the
# final image. Bookworm ships Python 3.11, same as gcr.io/distroless/python3-debian12.
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-venv \
    python3-pip \
    python3-dev \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Virtual environment at /venv (copied verbatim into the final stage).
RUN python3 -m venv /venv

# Clone application source to /QuakeWatch in the build stage.
RUN git clone --branch main --single-branch https://github.com/EduardUsatchev/QuakeWatch.git /QuakeWatch

RUN /venv/bin/pip install --no-cache-dir --upgrade pip \
    && /venv/bin/pip install --no-cache-dir -r /QuakeWatch/requirements.txt

RUN mkdir /QuakeWatch/logs 

 
# -----------------------------------------------------------------------------
# Final stage — distroless Python on Debian 12, nonroot user (UID 65532)
# -----------------------------------------------------------------------------
FROM gcr.io/distroless/python3-debian12:nonroot

# distroless nonroot defaults to /home/nonroot (often not writable under read-only roots).
# Point HOME and TMPDIR at /tmp so runtime state stays out of /home/nonroot.
ENV HOME=/tmp
ENV TMPDIR=/tmp

# Prevent Python from generating .pyc files on container startup.
ENV PYTHONDONTWRITEBYTECODE=1
# Send Python logs and prints straight to stdout/stderr.
ENV PYTHONUNBUFFERED=1

COPY --from=builder /venv /venv
COPY --from=builder --chown=65532:65532 --chmod=777 /QuakeWatch/ /QuakeWatch/

WORKDIR /QuakeWatch

EXPOSE 5000

# Application entrypoint uses the interpreter from the copied venv.
ENTRYPOINT ["/venv/bin/python3", "app.py"]
