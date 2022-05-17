#!/bin/bash

# Current Version: 1.4.6

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && bash ./CNIPDb/release.sh

## Function
# Environment Preparation
function EnvironmentPreparation() {
    rm -rf ./Temp ./cnipdb ./cnipdb_* && mkdir ./Temp ./cnipdb && cd ./Temp
    wget https://github.com/zhanhb/cidr-merger/releases/download/v$(curl -s --connect-timeout 15 "https://api.github.com/repos/zhanhb/cidr-merger/git/matching-refs/tags" | jq -Sr ".[].ref" | grep "^refs/tags/v" | tail -n 1 | sed "s/refs\/tags\/v//")/cidr-merger-linux-amd64 && mv ./cidr-merger-linux-amd64 ./cidr-merger && chmod +x ./cidr-merger
}
# Environment Cleanup
function EnvironmentCleanup() {
    cat ../cnipdb_*/asn_ipv4.txt | sort | uniq | ./cidr-merger -s > ../cnipdb/asn_ipv4.txt
    cat ../cnipdb_*/asn_ipv6.txt | sort | uniq | ./cidr-merger -s > ../cnipdb/asn_ipv6.txt
    cat ../cnipdb/asn_ipv4.txt ../cnipdb/asn_ipv6.txt > ../cnipdb/asn_ipv4_6.txt
    cat ../cnipdb_*/country_ipv4.txt | sort | uniq | ./cidr-merger -s > ../cnipdb/country_ipv4.txt
    cat ../cnipdb_*/country_ipv6.txt | sort | uniq | ./cidr-merger -s > ../cnipdb/country_ipv6.txt
    cat ../cnipdb/country_ipv4.txt ../cnipdb/country_ipv6.txt > ../cnipdb/country_ipv4_6.txt
    cd .. && rm -rf ./Temp
}
# Get Data from BGP
function GetDataFromBGP() {
    bgp_url=(
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt"
        "https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt"
    )
    for bgp_url_task in "${!bgp_url[@]}"; do
        curl -s --connect-timeout 15 "${bgp_url[$bgp_url_task]}" >> ./bgp_country_ipv4_6.tmp
    done
    bgp_country_ipv4_data=($(cat ./bgp_country_ipv4_6.tmp | grep -v "\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    bgp_country_ipv6_data=($(cat ./bgp_country_ipv4_6.tmp | grep -v "\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    for bgp_country_ipv4_data_task in "${!bgp_country_ipv4_data[@]}"; do
        echo "${bgp_country_ipv4_data[$bgp_country_ipv4_data_task]}" >> ./bgp_country_ipv4.tmp
    done
    for bgp_country_ipv6_data_task in "${!bgp_country_ipv6_data[@]}"; do
        echo "${bgp_country_ipv6_data[$bgp_country_ipv6_data_task]}" >> ./bgp_country_ipv6.tmp
    done
    mkdir ../cnipdb_bgp
    cat ./bgp_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_bgp/country_ipv4.txt
    cat ./bgp_country_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_bgp/country_ipv6.txt
    cat ../cnipdb_bgp/country_ipv4.txt ../cnipdb_bgp/country_ipv6.txt > ../cnipdb_bgp/country_ipv4_6.txt
}
# Get Data from DBIP
function GetDataFromDBIP() {
    dbip_url=(
        "https://download.db-ip.com/free/dbip-asn-lite-$(date '+%Y-%m').csv.gz"
        "https://download.db-ip.com/free/dbip-country-lite-$(date '+%Y-%m').csv.gz"
    )
    for dbip_url_task in "${!dbip_url[@]}"; do
        curl -s --connect-timeout 15 "${dbip_url[$dbip_url_task]}" >> ./dbip_${dbip_url_task}.csv.gz
        gzip -d ./dbip_${dbip_url_task}.csv.gz && mv ./dbip_${dbip_url_task}.csv ./$(echo ${dbip_url[$dbip_url_task]} | cut -d '/' -f 5 | cut -d '.' -f 1,2)
    done
    dbip_asn_ipv4_data=($(cat ./dbip-asn-lite-$(date '+%Y-%m').csv | grep 'China' | cut -d ',' -f 1,2 | tr ',' '-' | grep -v ':' | sort | uniq | awk "{ print $2 }"))
    dbip_asn_ipv6_data=($(cat ./dbip-asn-lite-$(date '+%Y-%m').csv | grep 'China' | cut -d ',' -f 1,2 | tr ',' '-' | grep ':' | sort | uniq | awk "{ print $2 }"))
    dbip_country_ipv4_data=($(cat ./dbip-country-lite-$(date '+%Y-%m').csv | grep 'CN' | cut -d ',' -f 1,2 | tr ',' '-' | grep -v ':' | sort | uniq | awk "{ print $2 }"))
    dbip_country_ipv6_data=($(cat ./dbip-country-lite-$(date '+%Y-%m').csv | grep 'CN' | cut -d ',' -f 1,2 | tr ',' '-' | grep ':' | sort | uniq | awk "{ print $2 }"))
    for dbip_asn_ipv4_data_task in "${!dbip_asn_ipv4_data[@]}"; do
        echo "${dbip_asn_ipv4_data[$dbip_asn_ipv4_data_task]}" >> ./dbip_asn_ipv4.tmp
    done
    for dbip_asn_ipv6_data_task in "${!dbip_asn_ipv6_data[@]}"; do
        echo "${dbip_asn_ipv6_data[$dbip_asn_ipv6_data_task]}" >> ./dbip_asn_ipv6.tmp
    done
    for dbip_country_ipv4_data_task in "${!dbip_country_ipv4_data[@]}"; do
        echo "${dbip_country_ipv4_data[$dbip_country_ipv4_data_task]}" >> ./dbip_country_ipv4.tmp
    done
    for dbip_country_ipv6_data_task in "${!dbip_country_ipv6_data[@]}"; do
        echo "${dbip_country_ipv6_data[$dbip_country_ipv6_data_task]}" >> ./dbip_country_ipv6.tmp
    done
    mkdir ../cnipdb_dbip
    cat ./dbip_asn_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_dbip/asn_ipv4.txt
    cat ./dbip_asn_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_dbip/asn_ipv6.txt
    cat ../cnipdb_dbip/asn_ipv4.txt ../cnipdb_dbip/asn_ipv6.txt > ../cnipdb_dbip/asn_ipv4_6.txt
    cat ./dbip_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_dbip/country_ipv4.txt
    cat ./dbip_country_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_dbip/country_ipv6.txt
    cat ../cnipdb_dbip/country_ipv4.txt ../cnipdb_dbip/country_ipv6.txt > ../cnipdb_dbip/country_ipv4_6.txt
}
# Get Data from GeoLite2
function GetDataFromGeoLite2() {
    geolite2_url=(
        "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key={GEOLITE2_TOKEN}&suffix=zip"
        "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key={GEOLITE2_TOKEN}&suffix=zip"
    )
    for geolite2_url_task in "${!geolite2_url[@]}"; do
        curl -s --connect-timeout 15 "${geolite2_url[$geolite2_url_task]}" >> ./geolite2_${geolite2_url_task}.zip
        unzip -o -d . ./geolite2_${geolite2_url_task}.zip && rm -rf ./geolite2_${geolite2_url_task}.zip
    done
    geolite2_asn_ipv4_data=($(cat ./GeoLite2-ASN-CSV_*/GeoLite2-ASN-Blocks-IPv4.csv | grep 'China' | cut -d ',' -f 1 | sort | uniq | awk "{ print $2 }"))
    geolite2_asn_ipv6_data=($(cat ./GeoLite2-ASN-CSV_*/GeoLite2-ASN-Blocks-IPv6.csv | grep 'China' | cut -d ',' -f 1 | sort | uniq | awk "{ print $2 }"))
    geolite2_country_ipv4_data=($(cat ./GeoLite2-Country-CSV_*/GeoLite2-Country-Blocks-IPv4.csv | grep '1814991,1814991' | cut -d ',' -f 1 | sort | uniq | awk "{ print $2 }"))
    geolite2_country_ipv6_data=($(cat ./GeoLite2-Country-CSV_*/GeoLite2-Country-Blocks-IPv6.csv | grep '1814991,1814991' | cut -d ',' -f 1 | sort | uniq | awk "{ print $2 }"))
    for geolite2_asn_ipv4_data_task in "${!geolite2_asn_ipv4_data[@]}"; do
        echo "${geolite2_asn_ipv4_data[$geolite2_asn_ipv4_data_task]}" >> ./geolite2_asn_ipv4.tmp
    done
    for geolite2_asn_ipv6_data_task in "${!geolite2_asn_ipv6_data[@]}"; do
        echo "${geolite2_asn_ipv6_data[$geolite2_asn_ipv6_data_task]}" >> ./geolite2_asn_ipv6.tmp
    done
    for geolite2_country_ipv4_data_task in "${!geolite2_country_ipv4_data[@]}"; do
        echo "${geolite2_country_ipv4_data[$geolite2_country_ipv4_data_task]}" >> ./geolite2_country_ipv4.tmp
    done
    for geolite2_country_ipv6_data_task in "${!geolite2_country_ipv6_data[@]}"; do
        echo "${geolite2_country_ipv6_data[$geolite2_country_ipv6_data_task]}" >> ./geolite2_country_ipv6.tmp
    done
    mkdir ../cnipdb_geolite2
    cat ./geolite2_asn_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_geolite2/asn_ipv4.txt
    cat ./geolite2_asn_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_geolite2/asn_ipv6.txt
    cat ../cnipdb_geolite2/asn_ipv4.txt ../cnipdb_geolite2/asn_ipv6.txt > ../cnipdb_geolite2/asn_ipv4_6.txt
    cat ./geolite2_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_geolite2/country_ipv4.txt
    cat ./geolite2_country_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_geolite2/country_ipv6.txt
    cat ../cnipdb_geolite2/country_ipv4.txt ../cnipdb_geolite2/country_ipv6.txt > ../cnipdb_geolite2/country_ipv4_6.txt
}
# Get Data from IANA
function GetDataFromIANA() {
    iana_url=(
        "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest"
        "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest"
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest"
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
        "https://ftp.apnic.net/stats/iana/delegated-iana-latest"
        "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
        "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest"
        "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest"
        "https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest"
        "https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest"
    )
    for iana_url_task in "${!iana_url[@]}"; do
        curl -s --connect-timeout 15 "${iana_url[$iana_url_task]}" >> ./iana_url.tmp
    done
    iana_asn_ipv4_data=($(cat ./iana_url.tmp | grep "CN|ipv4" | sort | uniq | awk "{ print $2 }"))
    iana_asn_ipv6_data=($(cat ./iana_url.tmp | grep "CN|ipv6" | sort | uniq | awk "{ print $2 }"))
    for iana_asn_ipv4_data_task in "${!iana_asn_ipv4_data[@]}"; do
        echo "$(echo $(echo ${iana_asn_ipv4_data[$iana_asn_ipv4_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_asn_ipv4_data[$iana_asn_ipv4_data_task]} | awk -F '|' '{ print 32 - log($5) / log(2) }'))" >> ./iana_asn_ipv4.tmp
    done
    for iana_asn_ipv6_data_task in "${!iana_asn_ipv6_data[@]}"; do
        echo "$(echo $(echo ${iana_asn_ipv6_data[$iana_asn_ipv6_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_asn_ipv6_data[$iana_asn_ipv6_data_task]} | awk -F '|' '{ print $5 }'))" >> ./iana_asn_ipv6.tmp
    done
    mkdir ../cnipdb_iana
    cat ./iana_asn_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_iana/asn_ipv4.txt
    cat ./iana_asn_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_iana/asn_ipv6.txt
    cat ../cnipdb_iana/asn_ipv4.txt ../cnipdb_iana/asn_ipv6.txt > ../cnipdb_iana/asn_ipv4_6.txt
}
# Get Data from IP2Location
function GetDataFromIP2Location() {
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
    ip2location_url=(
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DBASNLITEIPV6"
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DBASNLITE"
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DB1LITECSVIPV6"
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DB1LITECSV"
    )
    for ip2location_url_task in "${!ip2location_url[@]}"; do
        curl -s --connect-timeout 15 "${ip2location_url[$ip2location_url_task]}" >> ./ip2location_${ip2location_url_task}.zip
        unzip -o -d . ./ip2location_${ip2location_url_task}.zip && rm -rf ./ip2location_${ip2location_url_task}.zip
    done
    ip2location_asn_ipv4_data=($(cat ./IP2LOCATION-LITE-ASN.CSV | grep 'China' | cut -d ',' -f 3 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    ip2location_asn_ipv6_data=($(cat ./IP2LOCATION-LITE-ASN.IPV6.CSV | grep 'China' | cut -d ',' -f 3 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    ip2location_country_ipv4_data=($(cat ./IP2LOCATION-LITE-DB1.CSV | grep '"CN","China"' | cut -d ',' -f 1,2 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    ip2location_country_ipv6_data=($(cat ./IP2LOCATION-LITE-DB1.IPV6.CSV | grep '"CN","China"' | cut -d ',' -f 1,2 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    for ip2location_asn_ipv4_data_task in "${!ip2location_asn_ipv4_data[@]}"; do
        echo "${ip2location_asn_ipv4_data[$ip2location_asn_ipv4_data_task]}" >> ./ip2location_asn_ipv4.tmp
    done
    for ip2location_asn_ipv6_data_task in "${!ip2location_asn_ipv6_data[@]}"; do
        echo "${ip2location_asn_ipv6_data[$ip2location_asn_ipv6_data_task]}" >> ./ip2location_asn_ipv6.tmp
    done
    for ip2location_country_ipv4_data_task in "${!ip2location_country_ipv4_data[@]}"; do
        IP_NUM=$(echo "${ip2location_country_ipv4_data[$ip2location_country_ipv4_data_task]}" | cut -d '-' -f 1) && IPv4NUMConvert && IPv4_ADDR_START="${IPv4_ADDR}"
        IP_NUM=$(echo "${ip2location_country_ipv4_data[$ip2location_country_ipv4_data_task]}" | cut -d '-' -f 2) && IPv4NUMConvert && IPv4_ADDR_END="${IPv4_ADDR}"
        echo "${IPv4_ADDR_START}-${IPv4_ADDR_END}" >> ./ip2location_country_ipv4.tmp
    done
    for ip2location_country_ipv6_data_task in "${!ip2location_country_ipv6_data[@]}"; do
        IP_NUM=$(echo "${ip2location_country_ipv6_data[$ip2location_country_ipv6_data_task]}" | cut -d '-' -f 1) && IPv6NUMConvert && IPv6_ADDR_START="${IPv6_ADDR}"
        IP_NUM=$(echo "${ip2location_country_ipv6_data[$ip2location_country_ipv6_data_task]}" | cut -d '-' -f 2) && IPv6NUMConvert && IPv6_ADDR_END="${IPv6_ADDR}"
        echo "${IPv6_ADDR_START}-${IPv6_ADDR_END}" >> ./ip2location_country_ipv6.tmp
    done
    mkdir ../cnipdb_ip2location
    cat ./ip2location_asn_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ip2location/asn_ipv4.txt
    cat ./ip2location_asn_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ip2location/asn_ipv6.txt
    cat ../cnipdb_ip2location/asn_ipv4.txt ../cnipdb_ip2location/asn_ipv6.txt > ../cnipdb_ip2location/asn_ipv4_6.txt
    cat ./ip2location_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ip2location/country_ipv4.txt
    cat ./ip2location_country_ipv6.tmp | sort | uniq | ./cidr-merger -s | grep -v '^::ffff:' > ../cnipdb_ip2location/country_ipv6.txt
    cat ../cnipdb_ip2location/country_ipv4.txt ../cnipdb_ip2location/country_ipv6.txt > ../cnipdb_ip2location/country_ipv4_6.txt
}
# Get Data from IPdeny
function GetDataFromIPdeny() {
    ipdeny_url=(
        "http://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone"
        "http://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone"
    )
    for ipdeny_url_task in "${!ipdeny_url[@]}"; do
        curl -s --connect-timeout 15 "${ipdeny_url[$ipdeny_url_task]}" >> ./ipdeny_country_ipv4_6.tmp
    done
    ipdeny_country_ipv4_data=($(cat ./ipdeny_country_ipv4_6.tmp | grep -v "\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    ipdeny_country_ipv6_data=($(cat ./ipdeny_country_ipv4_6.tmp | grep -v "\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    for ipdeny_country_ipv4_data_task in "${!ipdeny_country_ipv4_data[@]}"; do
        echo "${ipdeny_country_ipv4_data[$ipdeny_country_ipv4_data_task]}" >> ./ipdeny_country_ipv4.tmp
    done
    for ipdeny_country_ipv6_data_task in "${!ipdeny_country_ipv6_data[@]}"; do
        echo "${ipdeny_country_ipv6_data[$ipdeny_country_ipv6_data_task]}" >> ./ipdeny_country_ipv6.tmp
    done
    mkdir ../cnipdb_ipdeny
    cat ./ipdeny_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ipdeny/country_ipv4.txt
    cat ./ipdeny_country_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ipdeny/country_ipv6.txt
    cat ../cnipdb_ipdeny/country_ipv4.txt ../cnipdb_ipdeny/country_ipv6.txt > ../cnipdb_ipdeny/country_ipv4_6.txt
}
# Get Data from IPIPdotNET
function GetDataFromIPIPdotNET() {
    ipipdotnet_url=(
        "https://cdn.ipip.net/17mon/country.zip"
    )
    for ipipdotnet_url_task in "${!ipipdotnet_url[@]}"; do
        curl -s --connect-timeout 15 "${ipipdotnet_url[$ipipdotnet_url_task]}" >> ./ipipdotnet_${ipipdotnet_url_task}.zip
        unzip -o -d . ./ipipdotnet_${ipipdotnet_url_task}.zip && rm -rf ./ipipdotnet_${ipipdotnet_url_task}.zip
    done
    ipipdotnet_country_ipv4_data=($(cat ./country.txt | grep 'CN' | cut -f 1 | sort | uniq | awk "{ print $2 }"))
    for ipipdotnet_country_ipv4_data_task in "${!ipipdotnet_country_ipv4_data[@]}"; do
        echo "${ipipdotnet_country_ipv4_data[$ipipdotnet_country_ipv4_data_task]}" >> ./ipipdotnet_country_ipv4.tmp
    done
    mkdir ../cnipdb_ipipdotnet
    cat ./ipipdotnet_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_ipipdotnet/country_ipv4.txt
}
# Get Data from IPtoASN
function GetDataFromIPtoASN() {
    iptoasn_url=(
        "https://iptoasn.com/data/ip2asn-v4.tsv.gz"
        "https://iptoasn.com/data/ip2asn-v6.tsv.gz"
        "https://iptoasn.com/data/ip2country-v4.tsv.gz"
        "https://iptoasn.com/data/ip2country-v6.tsv.gz"
    )
    for iptoasn_url_task in "${!iptoasn_url[@]}"; do
        curl -s --connect-timeout 15 "${iptoasn_url[$iptoasn_url_task]}" >> ./iptoasn_${iptoasn_url_task}.tsv.gz
        gzip -d ./iptoasn_${iptoasn_url_task}.tsv.gz && mv ./iptoasn_${iptoasn_url_task}.tsv ./$(echo ${iptoasn_url[$iptoasn_url_task]} | cut -d '/' -f 5 | cut -d '.' -f 1,2)
    done
    iptoasn_asn_ipv4_data=($(cat ./ip2asn-v4.tsv | grep 'China' | cut -f 1,2 | tr '\t' '-' | sort | uniq | awk "{ print $2 }"))
    iptoasn_asn_ipv6_data=($(cat ./ip2asn-v6.tsv | grep 'China' | cut -f 1,2 | tr '\t' '-' | sort | uniq | awk "{ print $2 }"))
    iptoasn_country_ipv4_data=($(cat ./ip2country-v4.tsv | grep 'CN' | cut -f 1,2 | tr '\t' '-' | sort | uniq | awk "{ print $2 }"))
    iptoasn_country_ipv6_data=($(cat ./ip2country-v6.tsv | grep 'CN' | cut -f 1,2 | tr '\t' '-' | sort | uniq | awk "{ print $2 }"))
    for iptoasn_asn_ipv4_data_task in "${!iptoasn_asn_ipv4_data[@]}"; do
        echo "${iptoasn_asn_ipv4_data[$iptoasn_asn_ipv4_data_task]}" >> ./iptoasn_asn_ipv4.tmp
    done
    for iptoasn_asn_ipv6_data_task in "${!iptoasn_asn_ipv6_data[@]}"; do
        echo "${iptoasn_asn_ipv6_data[$iptoasn_asn_ipv6_data_task]}" >> ./iptoasn_asn_ipv6.tmp
    done
    for iptoasn_country_ipv4_data_task in "${!iptoasn_country_ipv4_data[@]}"; do
        echo "${iptoasn_country_ipv4_data[$iptoasn_country_ipv4_data_task]}" >> ./iptoasn_country_ipv4.tmp
    done
    for iptoasn_country_ipv6_data_task in "${!iptoasn_country_ipv6_data[@]}"; do
        echo "${iptoasn_country_ipv6_data[$iptoasn_country_ipv6_data_task]}" >> ./iptoasn_country_ipv6.tmp
    done
    mkdir ../cnipdb_iptoasn
    cat ./iptoasn_asn_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_iptoasn/asn_ipv4.txt
    cat ./iptoasn_asn_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_iptoasn/asn_ipv6.txt
    cat ../cnipdb_iptoasn/asn_ipv4.txt ../cnipdb_iptoasn/asn_ipv6.txt > ../cnipdb_iptoasn/asn_ipv4_6.txt
    cat ./iptoasn_country_ipv4.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_iptoasn/country_ipv4.txt
    cat ./iptoasn_country_ipv6.tmp | sort | uniq | ./cidr-merger -s > ../cnipdb_iptoasn/country_ipv6.txt
    cat ../cnipdb_iptoasn/country_ipv4.txt ../cnipdb_iptoasn/country_ipv6.txt > ../cnipdb_iptoasn/country_ipv4_6.txt
}

## Process
# Call EnvironmentPreparation
EnvironmentPreparation
# Call GetDataFromBGP
GetDataFromBGP
# Call GetDataFromDBIP
GetDataFromDBIP
# Call GetDataFromGeoLite2
GetDataFromGeoLite2
# Call GetDataFromIANA
GetDataFromIANA
# Call GetDataFromIP2Location
GetDataFromIP2Location
# Cal GetDataFromIPdeny
GetDataFromIPdeny
# Call GetDataFromIPIPdotNET
GetDataFromIPIPdotNET
# Call GetDataFromIPtoASN
GetDataFromIPtoASN
# Call EnvironmentCleanup
EnvironmentCleanup
