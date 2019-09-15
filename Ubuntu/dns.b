"Zaliczenie: DNS i IPTABLES"
""
"1. Konfiguracja interfejsow sieciowych"
" - Interfejs eth0 10.38.100.$2" "checkInt -i eth0 -a \"10.38.100.$2\" -m \"255.0.0.0\"" 2
" - Brama domyslna" "checkInt -i eth0 -g \"10.0.0.1\"" 2
" - Interfejs eth1 192.168.1.1" "checkInt -i eth1 -a \"192.168.1.1\" -m \"255.255.255.240\"" 2
" - Adres serwera DNS" "cat /etc/resolv.conf | grep \"nameserver 127.0.0.1\" -c" 1
""
"2. Instalacja oprogramowania"
" - Server DNS" "isInstalled bind9" 2
""
"3. Konfiguracja serwera DNS"
" - Dzialanie serwera DNS" "service bind9 restart 1>/dev/NULL; pgrep named | wc -l" 6
" - Stworzona ACL" "named-checkconf -p | grep "acl.*\"lokalna_siec\".*{" -c" 1
" - ACL localhost" "named-checkconf -p | grep -A4 "acl.*\"lokalna_siec\".*{" | grep 127.0.0.1 -c" 1
" - ACL 192.168.1.1" "named-checkconf -p | grep -A4 "acl.*\"lokalna_siec\".*{" | grep 192.168.1.1 -c" 1
" - Konfiguracja adresow nasluchiwania" "named-checkconf -p | grep -A3 'listen-on' | grep lokalna_siec -c" 1
" - Konfiguracja forwardowania" "named-checkconf -p | grep 'forward.*first' -c" 1
" - Konfiguracja forwarderow" "named-checkconf -p | grep -A3 'forwarders' | grep 10.0.0.1 -c" 1
" - Strefa nazwa.local" "named-checkconf -p | grep zone | grep nazwa.local -c" 1
" - Strefa strona.local" "named-checkconf -p | grep zone | grep strona.local -c" 1
" - Strefa wyszukiwania wstecz" "named-checkconf -p | grep zone | grep 1.168.192 -c" 1
""
" - Strefa nazwa.local:"
" - SOA TTL" "named-checkzone -q -o - nazwa.local /etc/bind/db.nazwa.local | grep 'nazwa.local..*21600.*SOA' -c" 1
" - SOA Dane" "named-checkzone -q -o - nazwa.local /etc/bind/db.nazwa.local | grep 'SOA.*ns1.nazwa.local..*admin.nazwa.local.' -c" 2
" - SOA Parametry" "named-checkzone -q -o - nazwa.local /etc/bind/db.nazwa.local | grep 'SOA.*10800.*3600.*14400.*10800' -c" 2
" - Rekord NS" "named-checkzone -q -o - nazwa.local /etc/bind/db.nazwa.local | grep 'nazwa.local..*21600.*NS.*ns1.nazwa.local.' -c" 2
" - Rekord A: nazwa.local" "named-checkzone -q -o - nazwa.local /etc/bind/db.nazwa.local | grep '^nazwa.local..*21600.*A.*192.168.1.1' -c" 2
" - Rekord A: ns1.nazwa.local" "named-checkzone -q -o - nazwa.local /etc/bind/db.nazwa.local | grep '^ns1.nazwa.local..*21600.*A.*192.168.1.1' -c" 2
""
" - Strefa strona.local:" " - SOA TTL" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep 'strona.local..*259200.*SOA' -c" 1
" - SOA Dane" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep 'SOA.*ns1.nazwa.local..*admin.nazwa.local.' -c" 2
" - SOA Parametry" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep 'SOA.*7200.*3600.*7200.*10800' -c" 2
" - Rekord NS" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep 'strona.local..*259200.*NS.*ns1.nazwa.local.' -c" 2
" - Rekord CNAME" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep 'www.strona.local..*21600.*CNAME.*strona.local.' -c" 2
" - Rekord A: strona.local" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep '^strona.local..*21600.*A.*192.168.1.2' -c" 2
" - Rekord A: server.strona.local" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep '^server.strona.local..*21600.*A.*192.168.1.3' -c" 2
" - Rekord A: box.strona.local" "named-checkzone -q -o - strona.local /etc/bind/db.strona.local | grep '^box.strona.local..*518400.*A.*192.168.1.5' -c" 2
""
" - Strefa wyszukiwania wstecz:"
" - Rekord PTR: .1" "named-checkzone -q -o - 1.168.192.in-addr.arpa /etc/bind/db.wstecz.local | grep '^1.1.168.192.*21600.*PTR.*\snazwa.local' -c" 1
" - Rekord PTR: .1" "named-checkzone -q -o - 1.168.192.in-addr.arpa /etc/bind/db.wstecz.local | grep '^1.1.168.192.*21600.*PTR.*ns1.nazwa.local' -c" 1
" - Rekord PTR: .2" "named-checkzone -q -o - 1.168.192.in-addr.arpa /etc/bind/db.wstecz.local | grep '^2.1.168.192.*21600.*PTR.*\sstrona.local' -c" 2
" - Rekord PTR: .3" "named-checkzone -q -o - 1.168.192.in-addr.arpa /etc/bind/db.wstecz.local | grep '^3.1.168.192.*21600.*PTR.*server.strona.local' -c" 2
" - Rekord PTR: .5" "named-checkzone -q -o - 1.168.192.in-addr.arpa /etc/bind/db.wstecz.local | grep '^5.1.168.192.*518400.*PTR.*box.strona.local' -c" 2
""
"4. Konfiguracja IPTABLES" " - Skrypt zapora.sh" "ls -l /root | grep 'zapora.sh' -c" 1
" - Prawa pliku zapora.sh" "stat -c \"%A\" /root/zapora.sh | grep 'x' -c" 1
" - Domyslna polityka INPUT" "iptables -S | grep '\-P INPUT' | grep 'DROP' -c" 1
" - Domyslna polityka OUTPUT" "iptables -S | grep '\-P OUTPUT' | grep 'ACCEPT' -c" 1
" - Domyslna polityka FORWARD" "iptables -S | grep '\-P FORWARD' | grep 'DROP' -c" 1
" - NAT (Maskarada)" "iptables -t nat -S | grep 'POSTROUTING' | grep '\-o.*eth0' | grep '\-j.*MASQUERADE' -c" 3
" - Blokada FTP" "iptables -S | grep 'OUTPUT' | grep '\-o.*eth1' | grep '\-p.*tcp' | grep '\-dport.*21' | grep '\-j.*DROP' -c" 3
" - Logi SSH" "iptables -S | grep 'INPUT' | grep '\-i.*eth0' | grep '\-p.*tcp' | grep '\-dport.*22' | grep '\-j.*LOG' -c" 3
" - Logi SSH (NEW)" "iptables -S | grep 'INPUT' | grep '\-i.*eth0' | grep '\-p.*tcp' | grep '\-dport.*22' | grep '\-state.*NEW' | grep '\-j.*LOG' -c" 5
