@echo off
echo Setting Static Routes at %DATE% : %TIME% >> c:\staticroute\SetStaticRoutes.txt

rem THIS IS NOT RUN VIA SCHEDULED TASK ON THIS MACHINE

rem my.mycompany.com
route delete 165.193.78.212
route -p add 165.193.78.212 mask 255.255.255.255 10.101.248.1 IF 11

rem appname03.mycompany.com
route delete 165.193.78.223
route -p add 165.193.78.223 mask 255.255.255.255 10.101.248.1 IF 11

rem appname01.mycompany.com
route delete 165.193.78.183
route -p add 165.193.78.183 mask 255.255.255.255 10.101.248.1 IF 11

rem support.mycompany.com
route delete 165.193.78.227
route -p add 165.193.78.227 mask 255.255.255.255 10.101.248.1 IF 11

rem marketer.mycompany.com
route delete 165.193.78.202
route -p add 165.193.78.202 mask 255.255.255.255 10.101.248.1 IF 11

rem api.mycompany.com
route delete 165.193.78.208
route -p add 165.193.78.208 mask 255.255.255.255 10.101.248.1 IF 11

rem origin-www.mycompany.com
route delete 165.193.78.167
route -p add 165.193.78.167 mask 255.255.255.255 10.101.248.1 IF 11

rem labs.mycompany.com
route delete 165.193.78.204
route -p add 165.193.78.204 mask 255.255.255.255 10.101.248.1 IF 11

rem www.mycompany.com
route delete 165.193.78.201
route -p add 165.193.78.201 mask 255.255.255.255 10.101.248.1 IF 11

rem web.appname05-poll.com
route delete 165.193.78.209
route -p add 165.193.78.209 mask 255.255.255.255 10.101.248.1 IF 11