FROM docker.io/library/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -qq
RUN apt install -y --no-install-recommends software-properties-common dirmngr
RUN <<-EOF
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
  add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/"
EOF
RUN apt-get install -y --no-install-recommends r-base r-base-dev libxml2-dev libxslt-dev libssl-dev libgit2-dev wget

ADD Rprofile /etc/R/Rprofile.site
ADD install_sandpaper.R /tmp/install_sandpaper.R

# Setup Sandpaper and pandoc
RUN <<-EOF
  wget https://github.com/jgm/pandoc/releases/download/3.1.3/pandoc-3.1.3-1-amd64.deb -O /tmp/pandoc-3.1.3-1-amd64.deb
  dpkg -i /tmp/pandoc-3.1.3-1-amd64.deb
  R < /tmp/install_sandpaper.R --no-save
  mkdir /lesson
EOF

# Cleanup and Image Compression
RUN <<-EOF
  apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

WORKDIR /lesson
CMD ["/usr/bin/R", "--no-restore", "--no-save"]
