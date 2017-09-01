###
# Information and Instructions
###
# Dockerfile for the creating a gitlab runner for building android apps
# Extends: gitlab/gitlab-runner:latest
# https://hub.docker.com/r/gitlab/gitlab-runner/
# Installs the following software:
#
# wget tar unzip lib32stdc++6 lib32z1 Android SDK
###
## To build:
# docker build -f DockerfileRunnerAndroid -t gitlab-runner-android .
## To run, with login:
# docker run -it --name gitlab-runner-android gitlab-runner-android
# To run as a service
# docker service create --network ci-network --with-registry-auth --name gitlab-runner-android gitlab-runner-android:latest
## To run in background:
# docker run -d --name gitlab-runner-android gitlab-runner-android:latest
## To login when running
# docker exec -i -t (containerId) bash # obtain the containerId from docker ps
## to tag for pushing to aws, e.g.
# docker tag gitlab-runner-android:latest mononoke/gitlab-runner-android:1.0.0
## to push to aws
# docker push mononoke/gitlab-runner-android:1.0.0
## to pull from aws
# docker pull mononoke/gitlab-runner-android:1.0.0
################################################
# Some useful Docker commands
# To list running docker containers: "docker ps"
# When running in the background, the container needs to be stopped.
#  - type "docker ps" to get the container id
#  - type "docker stop {containerid}"
#  - type "docker rm {id}
# To log in to the container: "docker exec -it {containerid} bash"
# login to ecr aws ecr get-login --no-include-email --region ap-northeast-1 | sh
###############################################

FROM openjdk:8-jdk

MAINTAINER Fergus MacDermot <fergusmacdermot@gmail.com>

ENV ANDROID_COMPILE_SDK: "25"
ENV ANDROID_BUILD_TOOLS: "24.0.0"
ENV ANDROID_SDK_TOOLS: "24.4.1"

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1
RUN wget --quiet --output-document=android-sdk.tgz https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar --extract --gzip --file=android-sdk.tgz

RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter android-25
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter platform-tools
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter build-tools-24.0.0
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository
ENV ANDROID_HOME=$PWD/android-sdk-linux
ENV PATH=$PATH:$PWD/android-sdk-linux/platform-tools/
