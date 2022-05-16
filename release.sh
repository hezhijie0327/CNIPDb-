#!/bin/bash

# Current Version: 1.1.4

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && bash ./CNIPDb/release.sh

## Function
# Get Data
function GetData() {
    geoip_cn=(
        "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/text/cn.txt"
        "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/geolite2_country/country_cn.netset"
        "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/ip2location_country/ip2location_country_cn.netset"
        "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/ipdeny_country/id_country_cn.netset"
        "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/ipip_country/ipip_country_cn.netset"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt"
        "https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt"
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
    rm -rf ./cnipdb_* ./Temp && mkdir ./Temp && cd ./Temp && wget https://github.com/zhanhb/cidr-merger/releases/download/v$(curl -s --connect-timeout 15 "https://api.github.com/repos/zhanhb/cidr-merger/git/matching-refs/tags" | jq -Sr ".[].ref" | grep "^refs/tags/v" | tail -n 1 | sed "s/refs\/tags\/v//")/cidr-merger-linux-amd64 && mv ./cidr-merger-linux-amd64 ./cidr-merger && chmod +x ./cidr-merger
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
    geoip_cn_ipv4_data=($(cat ./geoip_cn.tmp | grep -v "\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    geoip_cn_ipv6_data=($(cat ./geoip_cn.tmp | grep -v "\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    iana_ipv4_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv4" | sort | uniq | awk "{ print $2 }"))
    iana_ipv6_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv6" | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    for geoip_cn_ipv4_data_task in "${!geoip_cn_ipv4_data[@]}"; do
        echo "${geoip_cn_ipv4_data[$geoip_cn_ipv4_data_task]}" >> ./cnipdb_ipv4.tmp
    done
    for geoip_cn_ipv6_data_task in "${!geoip_cn_ipv6_data[@]}"; do
        echo "${geoip_cn_ipv6_data[$geoip_cn_ipv6_data_task]}" >> ./cnipdb_ipv6.tmp
    done
    for iana_ipv4_data_task in "${!iana_ipv4_data[@]}"; do
        echo "$(echo $(echo ${iana_ipv4_data[$iana_ipv4_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_ipv4_data[$iana_ipv4_data_task]} | awk -F '|' '{ print 32 - log($5) / log(2) }'))" >> ./cnipdb_ipv4.tmp
    done
    for iana_ipv6_data_task in "${!iana_ipv6_data[@]}"; do
        echo "$(echo $(echo ${iana_ipv6_data[$iana_ipv6_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_ipv6_data[$iana_ipv6_data_task]} | awk -F '|' '{ print $5 }'))" >> ./cnipdb_ipv6.tmp
    done
    cat ./cnipdb_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ipv4.txt && cat ./cnipdb_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ipv6.txt && cat ../cnipdb_ipv4.txt ../cnipdb_ipv6.txt > ../cnipdb_combine.txt
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
