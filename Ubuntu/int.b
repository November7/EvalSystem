"Zaliczenie: Interfejsy sieciowe"
""
"1. Konfiguracja interfejsow sieciowych"
" - Interfejs enp0s3 10.38.$2.21" "checkInt -i enp0s3 -a \"10.38.$2.21\" -m \"255.0.0.0\"" 2
" - Brama domyslna" "checkInt -i enp0s3 -g \"10.0.0.1\"" 2
" - Interfejs enp0s8 192.168.$2.1" "checkInt -i enp0s8 -a \"192.168.$2.1\" -m \"255.255.255.240\"" 2
" - Interfejs enp0s9 172.16.$2.1" "checkInt -i enp0s9 -a \"172.16.$2.1\" -m \"255.255.255.192\"" 2
" - Adres serwera DNS" "cat /etc/resolv.conf | grep \"nameserver 8.8.8.8\" -c" 2
""
"2. Konfiguracja subinterfejsow sieciowych"
" - Interfejs enp0s3:jeden dhcp " "checkInt -i enp0s3:jeden" 2
" - Interfejs enp0s3:dwa 10.38.$2.22" "checkInt -i enp0s3:dwa -a \"10.38.$2.22\" -m \"255.0.0.0\"" 2
" - Interfejs enp0s3:trzy 10.38.$2.23" "checkInt -i enp0s3:trzy -a \"10.38.$2.23\" -m \"255.0.0.0\"" 2
""
"3. Parsowanie pliku interfaces"
" - Interface enp0s3" "parseFile /etc/network/interfaces iface enp0s3 inet static" 1
" - Subinterface fst" "parseFile /etc/network/interfaces iface enp0s3:jeden inet dhcp" 1
" - Subinterface sec" "parseFile /etc/network/interfaces iface enp0s3:dwa inet static" 1
" - Interface enp0s8" "parseFile /etc/network/interfaces iface enp0s8 inet static" 1
" - Interface enp0s9" "parseFile /etc/network/interfaces iface enp0s9 inet static" 1
" - Adres DNS" "parseFile /etc/network/interfaces dns-nameservers 8.8.8.8" 1
" - Brama domyslna" "parseFile /etc/network/interfaces gateway 10.0.0.1" 1
