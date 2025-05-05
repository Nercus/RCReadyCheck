#!/bin/bash

svn checkout https://repos.wowace.com/wow/libstub/tags/1.0 ./libs/LibStub
svn checkout https://repos.wowace.com/wow/callbackhandler/trunk/CallbackHandler-1.0 ./libs/CallbackHandler-1.0
git clone https://github.com/Nercus/NercUtils.git ./libs/NercUtils
