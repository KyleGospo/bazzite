FROM quay.io/fedora-ostree-desktops/kinoite:37

COPY etc /etc
COPY usr /usr

# Enable RPM Fusion and install it properly to avoid local override issues, install mesa-freeworld for proper video decode
RUN rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
rpm-ostree install rpmfusion-nonfree-release rpmfusion-free-release --uninstall=rpmfusion-free-release-$(rpm -E %fedora)-1.noarch --uninstall=rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch && \
rpm-ostree override remove mesa-va-drivers --install=mesa-va-drivers-freeworld --install=mesa-vdpau-drivers-freeworld && \
rpm-ostree override remove libavutil-free libswscale-free libswresample-free libavformat-free libavcodec-free --install=ffmpeg-libs --install=ffmpeg --install=libavcodec-freeworld

# Add needed Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo

# Install new packages, remove packages Steam likes to conflict with so the versions it's built against install instead.
RUN rpm-ostree install \
distrobox \
steam \
steam-devices \
mesa-dri-drivers \
mesa-filesystem \
mesa-libGL \
mesa-libglapi \
mesa-vulkan-drivers \
gamescope \
gamescope-session \
gamemode \
latencyflex-vulkan-layer \
vkBasalt \
mangohud \
duperemove

# Finalize
RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    rpm-ostree cleanup -m && \
    ostree container commit
