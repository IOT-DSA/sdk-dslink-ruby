#!/usr/bin/env bash
if [ "${TRAVIS_RUBY_VERSION}" == "2.1.0" ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ]
then
  if [ ! -d ${HOME}/.ssh ]
  then
    mkdir ${HOME}/.ssh
  fi

  git config --global user.name "Travis CI"
  git config --global user.email "travis@iot-dsa.org"
  openssl aes-256-cbc -K $encrypted_d4464b243baf_key -iv $encrypted_d4464b243baf_iv -in id_rsa.enc -out ${HOME}/.ssh/id_rsa -d
  chmod 600 ${HOME}/.ssh/id_rsa
  echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ${HOME}/.ssh/config
  if [ -d "doc" ]
  then
    rm -rf doc/
    yard
    git clone git@github.com:IOT-DSA/docs.git -b gh-pages --depth 1 tmp
    rm -rf tmp/sdks/ruby
    mkdir -p tmp/sdks/ruby
    cp -R doc/* tmp/sdks/ruby/
    cd tmp
    set +e
    git add .
    git commit -m "Update Docs for Ruby SDK"
    git push origin gh-pages
  fi
fi
