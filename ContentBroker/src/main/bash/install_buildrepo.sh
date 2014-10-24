#!/bin/bash

# author: Daniel M. de Oliveira

REVISION_NUMBER=`git rev-parse HEAD`
TARGET=/ci/BuildRepository/installation.$REVISION_NUMBER

mkdir $TARGET
mkdir $TARGET/ContentBroker
mkdir $TARGET/DAWeb
mkdir $TARGET/SipBuilder

cd /ci/DNSCore/ContentBroker
cp -r target/installation $TARGET/ContentBroker

cd /ci/DNSCore/DAWeb
cp target/daweb3-0.8.war $TARGET
cp doc/daweb3_properties.groovy.dev $TARGET/DAWeb/daweb3_properties.groovy.template

cd /ci/DNSCore/SIP-Builder
cp -r target/installation $TARGET/SipBuilder
