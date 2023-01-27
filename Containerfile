ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/kinoite:${FEDORA_MAJOR_VERSION}

COPY etc /etc
COPY usr /usr
RUN mkdir -p /var/lib/duperemove && \
ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning

# Enable RPM Fusion and install it properly to avoid local override issues
RUN rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
rpm-ostree install rpmfusion-nonfree-release rpmfusion-free-release --uninstall=rpmfusion-free-release-$(rpm -E %fedora)-1.noarch --uninstall=rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

# Add needed Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
wget https://copr.fedorainfracloud.org/coprs/jcrd/python3-hid/repo/fedora-$(rpm -E %fedora)/jcrd-python3-hid-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_jcrd-python3-hid.repo

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
$(rpm -qa --qf "%{NAME} ")
# The above prints every package installed, this acts similarly to rpm-ostree update when making an OCI image and resolves issues with installing Steam

# Install dock updater, this is done manually as it has proprietary parts and cannot be built in Copr.
RUN git clone https://github.com/KyleGospo/jupiter-dock-updater-bin.git && \
mv -v jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater

# Remove unneeded packages
RUN rpm-ostree override remove toolbox

# Install mesa-freeworld for proper video decode
RUN rpm-ostree override remove mesa-va-drivers --install=mesa-va-drivers-freeworld --install=mesa-vdpau-drivers-freeworld && \
rpm-ostree override remove libavutil-free libswscale-free libswresample-free libavformat-free libavcodec-free libavfilter-free libpostproc-free --install=ffmpeg-libs --install=ffmpeg --install=libavcodec-freeworld

# Finalize
RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    rpm-ostree cleanup -m && \
    ostree container commit
