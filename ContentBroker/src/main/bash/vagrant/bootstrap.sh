#!/usr/bin/env bash

bash -x /vagrant/regal-bootstrap.sh > vagrant-regal.log 2>&1
bash -x /vagrant/dns-bootstrap.sh > vagrant-dns.log 2>&1
