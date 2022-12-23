ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/kinoite:${FEDORA_MAJOR_VERSION}

COPY etc /etc
COPY usr /usr

# Override replace testing version of rpm-ostree so systems aren't bricked when layering packages. This will need to be removed relatively soon
RUN wget https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2022.18/2.fc37/x86_64/rpm-ostree-2022.18-2.fc37.x86_64.rpm && \
wget https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2022.18/2.fc37/x86_64/rpm-ostree-libs-2022.18-2.fc37.x86_64.rpm && \
rpm-ostree override replace rpm-ostree-2022.18-2.fc37.x86_64.rpm rpm-ostree-libs-2022.18-2.fc37.x86_64.rpm

# Enable RPM Fusion and install it properly to avoid local override issues, install mesa-freeworld for proper video decode
RUN rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
rpm-ostree install rpmfusion-nonfree-release rpmfusion-free-release --uninstall=rpmfusion-free-release-$(rpm -E %fedora)-1.noarch --uninstall=rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch && \
rpm-ostree override remove mesa-va-drivers --install=mesa-va-drivers-freeworld --install=mesa-vdpau-drivers-freeworld && \
rpm-ostree override remove libavutil-free libswscale-free libswresample-free libavformat-free libavcodec-free --install=ffmpeg-libs --install=ffmpeg --install=libavcodec-freeworld

# Add needed Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo

# Remove unneeded packages
RUN rpm-ostree override remove toolbox

# Install new packages
RUN rpm-ostree install \
distrobox \
steam \
steam-devices \
gamescope \
gamescope-session \
jupiter-fan-control \
gamemode \
latencyflex-vulkan-layer \
vkBasalt \
mangohud \
duperemove \
kdeconnectd \
$(rpm -qa --qf "%{NAME} ")
# The above prints every package installed, this acts similarly to rpm-ostree update when making an OCI image and resolves issues with installing Steam

# Finalize
RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    rpm-ostree cleanup -m && \
    ostree container commit
