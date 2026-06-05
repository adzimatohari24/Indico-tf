#!/bin/bash
# tf-check.sh - Automasi terraform init, fmt, validate, dan plan

RUN terraform init
RUN terraform fmt
RUN terraform validate
RUN terraform plan