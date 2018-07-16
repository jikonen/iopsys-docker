#!/bin/sh

echo ${PATH} | grep -q './:' || export PATH=./:$PATH
