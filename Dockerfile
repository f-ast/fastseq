FROM gitpod/workspace-full
USER root
RUN apt-get -y update
RUN apt-get -y install pkg-config zip g++ zlib1g-dev unzip curl git lsb-release
RUN apt-get -y install libssl-dev libcurl4-openssl-dev liblz-dev libbz2-dev liblzma-dev
RUN apt-get -y install python3-dev python3-pip python3-wheel python3-setuptools python3-numpy python3-h5py
RUN curl "https://storage.googleapis.com/deepvariant/packages/oss_clif/oss_clif.ubuntu-18.latest.tgz" > /tmp/oss_clif.tgz \
 && cd / \
 && tar xzf /tmp/oss_clif.tgz \
 && rm -f /tmp/oss_clif.tgz
RUN mkdir -p /workspace \
 && cd /workspace \
 && git clone https://github.com/tensorflow/tensorflow \
 && cd tensorflow \
 && git checkout v2.0.0 \
 && echo | ./configure
RUN cd /workspace \
 && curl -L -O https://github.com/bazelbuild/bazel/releases/download/0.26.1/bazel-0.26.1-installer-linux-x86_64.sh \
 && chmod +x bazel-*.sh \
 && ./bazel-0.26.1-installer-linux-x86_64.sh \
 && rm bazel-0.26.1-installer-linux-x86_64.sh
RUN cd /workspace \
 && git clone https://github.com/google/nucleus
RUN pyenv global 3.8.2
ENV TF_OPT "--copt=-msse4.1 --copt=-msse4.2 --copt=-mavx --copt=-O3"
RUN pip install numpy
RUN cd /workspace/nucleus \
 && bazel build -c opt ${TF_OPT} nucleus/...
RUN cd /workspace/nucleus \
 && RUN bazel build :licenses_zip
RUN chmod -R gitpod:gitpod /root/nucleus
RUN apt-get -y install graphviz
USER gitpod
