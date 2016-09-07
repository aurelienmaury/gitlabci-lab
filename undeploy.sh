#!/usr/bin/env bash

ansible-playbook ansible/undeploy.yml -e@gitlab_farm.vars.yml

