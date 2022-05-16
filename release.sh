#!/bin/bash

# Current Version: 1.2.3

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && bash ./CNIPDb/release.sh

## Function
# Get Data
function GetData() {
    geoip_cn=(
        "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt"
        "https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt"
        "https://raw.githubusercontent.com/v2fly/geoip/release/text/cn.txt"
        "http://www.ipdeny.com/ipblocks/data/countries/cn.zone"
        "http://www.ipdeny.com/ipv6/ipaddresses/blocks/cn.zone"
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
    sapics_ip_location_db=(
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/asn-country/asn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/asn-country/asn-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/dbip-country/dbip-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/dbip-country/dbip-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geo-asn-country/geo-asn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geo-asn-country/geo-asn-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geo-whois-asn-country/geo-whois-asn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geo-whois-asn-country/geo-whois-asn-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geolite2-country/geolite2-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geolite2-country/geolite2-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/iptoasn-country/iptoasn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/iptoasn-country/iptoasn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/webnet77-country/webnet77-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/webnet77-country/webnet77-country-ipv6.csv"
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
    for sapics_ip_location_db_task in "${!sapics_ip_location_db[@]}"; do
        curl -s --connect-timeout 15 "${sapics_ip_location_db[$sapics_ip_location_db_task]}" >> ./sapics_ip_location_db.tmp
    done
}
# Analyse Data
function AnalyseData() {
    geoip_cn_ipv4_data=($(cat ./geoip_cn.tmp | grep -v "\/0\|\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    geoip_cn_ipv6_data=($(cat ./geoip_cn.tmp | grep -v "\/0\|\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    iana_ipv4_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv4" | sort | uniq | awk "{ print $2 }"))
    iana_ipv6_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv6" | sort | uniq | awk "{ print $2 }"))
    sapics_ip_location_db_ipv4_data=($(cat ./sapics_ip_location_db.tmp | grep 'CN' | grep '.' | cut -d ',' -f 1,2 | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    sapics_ip_location_db_ipv6_data=($(cat ./sapics_ip_location_db.tmp | grep 'CN' | grep ':' | cut -d ',' -f 1,2 | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
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
    for sapics_ip_location_db_ipv4_data_task in "${!sapics_ip_location_db_ipv4_data[@]}"; do
        echo "${sapics_ip_location_db_ipv4_data[$sapics_ip_location_db_ipv4_data_task]}" >> ./cnipdb_ipv4.tmp
    done
    for sapics_ip_location_db_ipv6_data_task in "${!sapics_ip_location_db_ipv6_data[@]}"; do
        echo "${sapics_ip_location_db_ipv6_data[$sapics_ip_location_db_ipv6_data_task]}" >> ./cnipdb_ipv6.tmp
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
