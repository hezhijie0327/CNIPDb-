#!/bin/bash

# Current Version: 1.3.1

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && bash ./CNIPDb/release.sh

## Function
# Get Data
function GetData() {
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
    ip2location=(
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DB1LITECSVIPV6"
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DB1LITECSV"
    )
    plain_geoip_cn=(
        "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt"
        "https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt"
        "http://www.ipdeny.com/ipblocks/data/countries/cn.zone"
        "http://www.ipdeny.com/ipv6/ipaddresses/blocks/cn.zone"
    )
    sapics_ip_location_db=(
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/dbip-country/dbip-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/dbip-country/dbip-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geo-whois-asn-country/geo-whois-asn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geo-whois-asn-country/geo-whois-asn-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geolite2-country/geolite2-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/geolite2-country/geolite2-country-ipv6.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/iptoasn-country/iptoasn-country-ipv4.csv"
        "https://raw.githubusercontent.com/sapics/ip-location-db/master/iptoasn-country/iptoasn-country-ipv6.csv"
    )
    rm -rf ./cnipdb_* ./Temp && mkdir ./Temp && cd ./Temp
    for iana_default_task in "${!iana_default[@]}"; do
        curl -s --connect-timeout 15 "${iana_default[$iana_default_task]}" >> ./iana_default.tmp
    done
    for iana_extended_task in "${!iana_extended[@]}"; do
        curl -s --connect-timeout 15 "${iana_extended[$iana_extended_task]}" >> ./iana_extended.tmp
    done
    for ip2location_task in "${!ip2location[@]}"; do
        curl -s --connect-timeout 15 "${ip2location[$ip2location_task]}" >> ./ip2location_${ip2location_task}.zip
        unzip -o -d . ./ip2location_${ip2location_task}.zip && rm -rf ./ip2location_${ip2location_task}.zip
    done
    for plain_geoip_cn_task in "${!plain_geoip_cn[@]}"; do
        curl -s --connect-timeout 15 "${plain_geoip_cn[$plain_geoip_cn_task]}" >> ./plain_geoip_cn.tmp
    done
    for sapics_ip_location_db_task in "${!sapics_ip_location_db[@]}"; do
        curl -s --connect-timeout 15 "${sapics_ip_location_db[$sapics_ip_location_db_task]}" >> ./sapics_ip_location_db.tmp
    done
}
# Get IP Tools
function GetIPTools() {
    wget https://github.com/zhanhb/cidr-merger/releases/download/v$(curl -s --connect-timeout 15 "https://api.github.com/repos/zhanhb/cidr-merger/git/matching-refs/tags" | jq -Sr ".[].ref" | grep "^refs/tags/v" | tail -n 1 | sed "s/refs\/tags\/v//")/cidr-merger-linux-amd64 && mv ./cidr-merger-linux-amd64 ./cidr-merger && chmod +x ./cidr-merger
}
# Analyse Data
function AnalyseData() {
    iana_ipv4_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv4" | sort | uniq | awk "{ print $2 }"))
    iana_ipv6_data=($(cat ./iana_default.tmp ./iana_extended.tmp | grep "CN|ipv6" | sort | uniq | awk "{ print $2 }"))
    plain_geoip_cn_ipv4_data=($(cat ./plain_geoip_cn.tmp | grep -v "\/0\|\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    plain_geoip_cn_ipv6_data=($(cat ./plain_geoip_cn.tmp | grep -v "\/0\|\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    sapics_ip_location_db_ipv4_data=($(cat ./sapics_ip_location_db.tmp | grep 'CN' | grep '.' | cut -d ',' -f 1,2 | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    sapics_ip_location_db_ipv6_data=($(cat ./sapics_ip_location_db.tmp | grep 'CN' | grep ':' | cut -d ',' -f 1,2 | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
}
# Decode Data
function DecodeData() {
    function IPv4NUMConvert() {
        IPv4_ADDR=""
        W=$(echo "obase=10;($IP_NUM / (256^3)) % 256" | bc)
        X=$(echo "obase=10;($IP_NUM / (256^2)) % 256" | bc)
        Y=$(echo "obase=10;($IP_NUM / (256^1)) % 256" | bc)
        Z=$(echo "obase=10;($IP_NUM / (256^0)) % 256" | bc)
        IPv4_ADDR="$W.$X.$Y.$Z"
    }
    function IPv6NUMConvert() {
        IPv6_ADDR=""
        A=$(echo "obase=16;($IP_NUM / (65536^7)) % 65536" | bc)
        B=$(echo "obase=16;($IP_NUM / (65536^6)) % 65536" | bc)
        C=$(echo "obase=16;($IP_NUM / (65536^5)) % 65536" | bc)
        D=$(echo "obase=16;($IP_NUM / (65536^4)) % 65536" | bc)
        E=$(echo "obase=16;($IP_NUM / (65536^3)) % 65536" | bc)
        F=$(echo "obase=16;($IP_NUM / (65536^2)) % 65536" | bc)
        G=$(echo "obase=16;($IP_NUM / (65536^1)) % 65536" | bc)
        H=$(echo "obase=16;($IP_NUM / (65536^0)) % 65536" | bc)
        IPv6_ADDR="$A:$B:$C:$D:$E:$F:$G:$H"
    }
    ip2location_ipv4_raw_data=($(cat ./IP2LOCATION-LITE-DB1.CSV | grep '"CN","China"' | cut -d ',' -f 1,2 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    ip2location_ipv6_raw_data=($(cat ./IP2LOCATION-LITE-DB1.IPV6.CSV | grep '"CN","China"' | cut -d ',' -f 1,2 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    for ip2location_ipv4_raw_data_task in "${!ip2location_ipv4_raw_data[@]}"; do
        IP_NUM=$(echo "${ip2location_ipv4_raw_data[$ip2location_ipv4_raw_data_task]}" | cut -d '-' -f 1) && IPv4NUMConvert && IPv4_ADDR_START="${IPv4_ADDR}"
        IP_NUM=$(echo "${ip2location_ipv4_raw_data[$ip2location_ipv4_raw_data_task]}" | cut -d '-' -f 2) && IPv4NUMConvert && IPv4_ADDR_END="${IPv4_ADDR}"
        echo "${IPv4_ADDR_START}-${IPv4_ADDR_END}" >> ./cnipdb_ipv4.tmp
    done
    for ip2location_ipv6_raw_data_task in "${!ip2location_ipv6_raw_data[@]}"; do
        IP_NUM=$(echo "${ip2location_ipv6_raw_data[$ip2location_ipv6_raw_data_task]}" | cut -d '-' -f 1) && IPv6NUMConvert && IPv6_ADDR_START="${IPv6_ADDR}"
        IP_NUM=$(echo "${ip2location_ipv6_raw_data[$ip2location_ipv6_raw_data_task]}" | cut -d '-' -f 2) && IPv6NUMConvert && IPv6_ADDR_END="${IPv6_ADDR}"
        echo "${IPv6_ADDR_START}-${IPv6_ADDR_END}" >> ./cnipdb_ipv6.tmp
    done
}
# Output Data
function OutputData() {
    for iana_ipv4_data_task in "${!iana_ipv4_data[@]}"; do
        echo "$(echo $(echo ${iana_ipv4_data[$iana_ipv4_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_ipv4_data[$iana_ipv4_data_task]} | awk -F '|' '{ print 32 - log($5) / log(2) }'))" >> ./cnipdb_ipv4.tmp
    done
    for iana_ipv6_data_task in "${!iana_ipv6_data[@]}"; do
        echo "$(echo $(echo ${iana_ipv6_data[$iana_ipv6_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_ipv6_data[$iana_ipv6_data_task]} | awk -F '|' '{ print $5 }'))" >> ./cnipdb_ipv6.tmp
    done
    for plain_geoip_cn_ipv4_data_task in "${!plain_geoip_cn_ipv4_data[@]}"; do
        echo "${plain_geoip_cn_ipv4_data[$plain_geoip_cn_ipv4_data_task]}" >> ./cnipdb_ipv4.tmp
    done
    for plain_geoip_cn_ipv6_data_task in "${!plain_geoip_cn_ipv6_data[@]}"; do
        echo "${plain_geoip_cn_ipv6_data[$plain_geoip_cn_ipv6_data_task]}" >> ./cnipdb_ipv6.tmp
    done
    for sapics_ip_location_db_ipv4_data_task in "${!sapics_ip_location_db_ipv4_data[@]}"; do
        echo "${sapics_ip_location_db_ipv4_data[$sapics_ip_location_db_ipv4_data_task]}" >> ./cnipdb_ipv4.tmp
    done
    for sapics_ip_location_db_ipv6_data_task in "${!sapics_ip_location_db_ipv6_data[@]}"; do
        echo "${sapics_ip_location_db_ipv6_data[$sapics_ip_location_db_ipv6_data_task]}" >> ./cnipdb_ipv6.tmp
    done
    cat ./cnipdb_ipv4.tmp | grep '.' | sort | uniq | ./cidr-merger -s > ../cnipdb_ipv4.txt && cat ./cnipdb_ipv6.tmp | grep ':' | sort | uniq | ./cidr-merger -s | grep -v "^::ffff:" > ../cnipdb_ipv6.txt && cat ../cnipdb_ipv4.txt ../cnipdb_ipv6.txt > ../cnipdb_combine.txt
    cd .. && rm -rf ./Temp
    exit 0
}

## Process
# Call GetData
GetData
# Call GetIPTools
GetIPTools
# Call DecodeData
DecodeData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
