FROM ghcr.io/ublue-os/kinoite-nvidia:latest

COPY etc /etc
COPY usr /usr
RUN ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning

# Re-enable RPMFusion repos & add Copr repos
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-free{,-updates}.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo

# Install new packages
RUN rpm-ostree install \
    distrobox \
    steam \
    steam-devices \
    gamescope \
    gamescope-session \
    jupiter-fan-control \
    jupiter-hw-support-btrfs \
    steamdeck-kde-presets \
    gamemode \
    latencyflex-vulkan-layer \
    vkBasalt \
    mangohud \
    duperemove \
    kdeconnectd \
    btop \
    fish \
    kate \
    openrgb-udev-rules \
    $(rpm -qa --qf "%{NAME} ")

# Install dock updater, this is done manually as it has proprietary parts and cannot be built in Copr.
RUN git clone https://github.com/KyleGospo/jupiter-dock-updater-bin.git && \
    mv -v jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater

# Remove unneeded packages
RUN rpm-ostree override remove toolbox

# Install mesa freeworld components and ffmpeg for hardware accelerated video decode
RUN rpm-ostree override remove \
    mesa-va-drivers \
    libavutil-free \
    libswscale-free \
    libswresample-free \
    libavformat-free \
    libavcodec-free \
    libavfilter-free \
    libpostproc-free \
    --install=mesa-va-drivers-freeworld.x86_64 \
    --install=mesa-va-drivers-freeworld.i686 \
    --install=mesa-vdpau-drivers-freeworld \
    --install=libva-intel-driver \
    --install=nvidia-vaapi-driver \
    --install=ffmpeg-libs \
    --install=ffmpeg \
    --install=libavcodec-freeworld

# Cleanup & Finalize
RUN sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-free{,-updates}.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    rpm-ostree cleanup -m && \
    rm -rf \
    /tmp/* \
    /var/* && \
    mkdir -p /var/lib/duperemove && \
    ostree container commit
