# Official Odoo 20 + up-to-date build + Paper Muncher + your dependencies
FROM odoo:20

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Up-to-date Odoo: the official image is not published every day and falls behind.
# ODOO_RELEASE empty = the build shipped in the official image.
# A date (e.g. 20261008) = installs that nightly build on top.
# "latest" = the latest published nightly (rebuild with --no-cache to refresh it).
ARG ODOO_RELEASE=""
RUN if [ -n "$ODOO_RELEASE" ]; then \
        if [ "$ODOO_RELEASE" = "latest" ]; then \
            ODOO_RELEASE="$(curl -fsSL "https://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/" \
              | grep -oE "odoo_${ODOO_VERSION}\.[0-9]{8}_all\.deb" | sort -u | tail -1 \
              | grep -oE '[0-9]{8}')"; \
        fi; \
        curl -fsSL -o /tmp/odoo.deb \
          "https://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb" \
        && apt-get update \
        && apt-get install -y --no-install-recommends -o Dpkg::Options::="--force-confold" /tmp/odoo.deb \
        && chown odoo /etc/odoo/odoo.conf \
        && rm -rf /var/lib/apt/lists/* /tmp/odoo.deb; \
    fi

# Paper Muncher: Odoo 20's new PDF engine. The official image does not ship it.
# Packages exist for amd64 only: on arm64 (Apple Silicon Macs) it is skipped and
# Odoo keeps printing with wkhtmltopdf.
ARG PAPER_MUNCHER_VERSION=0.9.0
ARG TARGETARCH
RUN ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    if [ "$ARCH" = "amd64" ]; then \
        curl -fsSL -o /tmp/paper-muncher.deb \
          "https://github.com/odoo/paper-muncher/releases/download/v${PAPER_MUNCHER_VERSION}/paper-muncher_v${PAPER_MUNCHER_VERSION}_noble_amd64.deb" \
        && apt-get update \
        && apt-get install -y --no-install-recommends /tmp/paper-muncher.deb \
        && rm -rf /var/lib/apt/lists/* /tmp/paper-muncher.deb; \
    else \
        echo "Paper Muncher has no package for $ARCH: skipped"; \
    fi

# System packages (apt), passed from compose.yaml via APT_PACKAGES.
ARG APT_PACKAGES=""
RUN if [ -n "$APT_PACKAGES" ]; then \
        apt-get update \
        && apt-get install -y --no-install-recommends $APT_PACKAGES \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Python libraries (pip), listed in requirements.txt.
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --break-system-packages -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

USER odoo
