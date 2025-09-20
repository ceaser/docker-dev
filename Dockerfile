FROM archlinux:latest

ARG DEV_UID
ENV DEV_UID=${DEV_UID:-1000}
ARG DEV_GID
ENV DEV_GID=${DEV_GID:-1000}
ARG CHANGE_HOME_DIR_OWNERSHIP
ENV CHANGE_HOME_DIR_OWNERSHIP=${CHANGE_HOME_DIR_OWNERSHIP:-false}

RUN pacman -Syu --noconfirm --noprogressbar \
  && pacman -S --noconfirm --noprogressbar --needed  \
            alacritty \
            aws-cli \
            base  \
            base-devel \
            bash-completion \
            ctags \
            dnsutils \
            docker \
            fakeroot \
            git \
            gnupg \
            go \
            go-tools \
            htop \
            inetutils \
            iproute2 \
            jq \
            keychain \
            kubectl \
            libcap \
            libguestfs \
            linux-firmware \
            lvm2 \
            man \
            mdadm \
            mosh \
            ncdu \
            neovim \
            netcat \
            nethogs \
            openssh \
            pam \
            parallel \
            pv \
            python-neovim \
            python-pip \
            ripgrep \
            ruby \
            sysstat \
            tmux \
            ttf-jetbrains-mono-nerd \
            unzip \
            vi \
            vim \
            yadm \
  && ln -sf /usr/share/zoneinfo/US/Mountain /etc/localtime

RUN set -e \
  && echo "Set disable_coredump false" > /etc/sudo.conf \
  && sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers \
  && ssh-keygen -A  \
  && echo 'root:roottoor' | chpasswd \
  && sed -i -e 's/^UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

RUN (useradd -m clarry || :) \
  && usermod -G wheel clarry \
  && mkdir -p /home/clarry/.ssh \
  && su -c 'git clone https://aur.archlinux.org/yay-bin.git /home/clarry/yay-bin' clarry \
  && su -c 'cd /home/clarry/yay-bin && makepkg' clarry \
  && echo 'clarry ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/clarry \
  && echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/wheel \
  && echo 'clarry:clarry' | chpasswd \
  && pacman -U --noconfirm --needed /home/clarry/yay-bin/*.zst \
  && su -c 'yay -Sw --noconfirm --needed flux-bin' clarry \
  && su -c 'cd /home/clarry/.cache/yay/flux-bin && makepkg' clarry \
  && pacman -U --noconfirm --needed /home/clarry/.cache/yay/flux-bin/*.zst \
  && su -c 'rm -rf /home/clarry/yay-bin' clarry \
  && chown -R clarry /home/clarry \
  && chgrp -R clarry /home/clarry

ENV YADM_COMPATIBILITY=1
EXPOSE 22/tcp
EXPOSE 60000:61000/udp
#VOLUME ["/home/clarry/"]
#RUN chown 1000:1000 /home/clarry
ADD init.sh /init.sh
RUN chmod 755 /init.sh
ENTRYPOINT ["/init.sh"]
CMD ["/usr/sbin/sshd", "-D"]
