#!/bin/sh
rm -rf ./db/ips.db

wget -O irc-proxy.db http://irc-proxies.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/irc-proxy.db | sort | uniq >> ./db/ip.db
rm -rf irc-proxy.db

wget -O proxy-heaven.db http://proxy-heaven.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/proxy-heaven.db | sort | uniq >> ./db/ip.db
rm -rf proxy-heaven.db

wget -O google-proxies.db http://google-proxies.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/google-proxies.db | sort | uniq >> ./db/ip.db
rm -rf google-proxies.db

wget -O golden-socks.db http://golden-socks.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/golden-socks.db | sort | uniq >> ./db/ip.db
rm -rf golden-socks.db

wget -O free-proxyserverlist.db http://free-proxyserverlist.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' free-proxyserverlist.db | sort | uniq >> ./db/ip.db
rm -rf free-proxyserverlist.db

wget -O proxyhell.db http://proxyhell.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/proxyhell.db | sort | uniq >> ./db/ip.db
rm -rf proxyhell.db

wget -O seoproxies.db http://seoproxies.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/seoproxies.db | sort | uniq >> ./db/ip.db
rm -rf seoproxies.db

wget -O us-socks.db http://us-socks.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/us-socks.db | sort | uniq >> ./db/ip.db
rm -rf us-socks.db

wget -O new-daily-proxies.db http://new-daily-proxies.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/new-daily-proxies.db | sort | uniq >> ./db/ip.db
rm -rf new-daily-proxies.db

wget -O proxy-server-free.db http://proxy-server-free.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/proxy-server-free.db | sort | uniq >> ./db/ip.db
rm -rf proxy-server-free.db

wget -O vip-socks.db http://www.vip-socks.net/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/vip-socks.db | sort | uniq >> ./db/ip.db
rm -rf vip-socks.db

wget -O live-socks.db http://www.live-socks.net/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/live-socks.db | sort | uniq >> ./db/ip.db
rm -rf live-socks.db

wget -O socks24.db http://www.socks24.org/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/socks24.db | sort | uniq >> ./db/ip.db
rm -rf socks24.db

wget -O socks5list.db http://www.socks5list.com/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/socks5list.db | sort | uniq >> ./db/ip.db
rm -rf socks5list.db

wget -O ./db/test.db https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=5.36.36.25&port=


wget -O proxies24.db http://www.proxies24.org/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/proxies24.db | sort | uniq >> ./db/ip.db
rm -rf proxies24.db

wget -O googlepassedproxies.db http://googlepassedproxies.com/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/googlepassedproxies.db | sort | uniq >> ./db/ip.db
rm -rf googlepassedproxies.db

wget -O dan.db https://www.dan.me.uk/torlist/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/dan.db | sort | uniq >> ./db/ip.db
rm -rf dan.db

grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/test.db | sort | uniq >> ./db/ip.db
rm -rf test.db

grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./db/ip.db | sort | uniq >> ./db/ips.db
rm -rf ./db/ip.db