#!/bin/bash

# Current Version: 1.0.3

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && bash ./CNIPDb/release.sh

## Function
# Get Data
function GetData() {
    geoip_cn=(
        "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/text/cn.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt"
        "https://raw.githubusercontent.com/v2fly/geoip/release/text/cn.txt"
    )
    iana_default=(
        "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest"
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
        "https://ftp.apnic.net/stats/iana/delegated-iana-latest"
        "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest"
        "https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest"
    )
    iana_extended=(
        "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest"
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest"
        "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
        "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest"
        "https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest"
    )
    rm -rf ./cnipdb_* ./Temp && mkdir ./Temp && cd ./Temp
    for geoip_cn_task in "${!geoip_cn[@]}"; do
        curl -s --connect-timeout 15 "${geoip_cn[$geoip_cn_task]}" >> ./geoip_cn.tmp
    done
    for iana_default_task in "${!iana_default[@]}"; do
        curl -s --connect-timeout 15 "${iana_default[$iana_default_task]}" >> ./iana_default.tmp
    done
    for iana_extended_task in "${!iana_extended[@]}"; do
        curl -s --connect-timeout 15 "${iana_extended[$iana_extended_task]}" >> ./iana_extended.tmp
    done
}
# Analyse Data
function AnalyseData() {
    geoip_cn_ipv4_data=($(cat ./geoip_cn.tmp | grep -v ':' | sort | uniq | awk "{ print $2 }"))
    geoip_cn_ipv6_data=($(cat ./geoip_cn.tmp | grep ':' | sort | uniq | awk "{ print $2 }"))
    iana_ipv4_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv4" | sort | uniq | awk "{ print $2 }"))
    iana_ipv6_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv6" | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    export IPv4_REGEX="^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}/(([0-9])|([1-2][0-9])|(3[0-2]){1,2})$"
    export IPv6_REGEX="^(([0-9a-f]{1,4}:){7,7}[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,7}:|([0-9a-f]{1,4}:){1,6}:[0-9a-f]{1,4}|([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}|([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}|([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}|([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}|[0-9a-f]{1,4}:((:[0-9a-f]{1,4}){1,6})|:((:[0-9a-f]{1,4}){1,7}|:)|fe80:(:[0-9a-f]{0,4}){0,4}%[0-9a-z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-f]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/(([0-9])|([1-9][0-9])|(1[0-1][0-9])|(12[0-8]){1,3})$"
    for geoip_cn_ipv4_data_task in "${!geoip_cn_ipv4_data[@]}"; do
        echo "$(echo ${geoip_cn_ipv4_data[$geoip_cn_ipv4_data_task]} | grep -E ${IPv4_REGEX})" >> ./cnipdb_ipv4.tmp
    done
    for geoip_cn_ipv6_data_task in "${!geoip_cn_ipv6_data[@]}"; do
        echo "$(echo ${geoip_cn_ipv6_data[$geoip_cn_ipv6_data_task]} | grep -E ${IPv6_REGEX})" >> ./cnipdb_ipv6.tmp
    done
    for iana_ipv4_data_task in "${!iana_ipv4_data[@]}"; do
        echo "$(echo $(echo ${iana_ipv4_data[$iana_ipv4_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_ipv4_data[$iana_ipv4_data_task]} | awk -F '|' '{ print 32 - log($5) / log(2) }') | grep -E ${IPv4_REGEX})" >> ./cnipdb_ipv4.tmp
    done
    for iana_ipv6_data_task in "${!iana_ipv6_data[@]}"; do
        echo "$(echo $(echo ${iana_ipv6_data[$iana_ipv6_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_ipv6_data[$iana_ipv6_data_task]} | awk -F '|' '{ print $5 }') | grep -E ${IPv6_REGEX})" >> ./cnipdb_ipv6.tmp
    done
    cat ./cnipdb_ipv4.tmp | sort | uniq > ../cnipdb_ipv4.txt && cat ./cnipdb_ipv6.tmp | sort | uniq > ../cnipdb_ipv6.txt && cat ../cnipdb_ipv4.txt ../cnipdb_ipv6.txt > ../cnipdb_combine.txt
    cd .. && rm -rf ./Temp
    exit 0
}

## Process
# Call GetData
GetData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
