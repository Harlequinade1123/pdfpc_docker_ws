FROM ubuntu:20.04

ARG USERNAME=slides
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    biber \
    dbus-x11 \
    fonts-noto-cjk \
    ghostscript \
    git \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-gtk3 \
    latexmk \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libcanberra-gtk3-module \
    librsvg2-common \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    make \
    perl \
    pdfpc \
    poppler-utils \
    texlive-fonts-recommended \
    texlive-lang-japanese \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-luatex \
    texlive-pictures \
    texlive-xetex \
    x11-apps \
    xauth \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}"

RUN mkdir -p /workspace/projects \
    && chown -R "${USERNAME}:${USERNAME}" /workspace

WORKDIR /workspace/projects
USER ${USERNAME}

CMD ["bash"]
