#!/bin/sh
rm -rf ips.db

wget -O irc-proxy.db http://irc-proxies.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' irc-proxy.db | sort | uniq >> ip.db
rm -rf irc-proxy.db

wget -O proxy-heaven.db http://proxy-heaven.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' proxy-heaven.db | sort | uniq >> ip.db
rm -rf proxy-heaven.db

wget -O google-proxies.db http://google-proxies.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' google-proxies.db | sort | uniq >> ip.db
rm -rf google-proxies.db

wget -O golden-socks.db http://golden-socks.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' golden-socks.db | sort | uniq >> ip.db
rm -rf golden-socks.db

wget -O free-proxyserverlist.db http://free-proxyserverlist.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' free-proxyserverlist.db | sort | uniq >> ip.db
rm -rf free-proxyserverlist.db

wget -O proxyhell.db http://proxyhell.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' proxyhell.db | sort | uniq >> ip.db
rm -rf proxyhell.db

wget -O seoproxies.db http://seoproxies.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' seoproxies.db | sort | uniq >> ip.db
rm -rf seoproxies.db

wget -O us-socks.db http://us-socks.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' us-socks.db | sort | uniq >> ip.db
rm -rf us-socks.db

wget -O new-daily-proxies.db http://new-daily-proxies.blogspot.fr/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' new-daily-proxies.db | sort | uniq >> ip.db
rm -rf new-daily-proxies.db

wget -O proxy-server-free.db http://proxy-server-free.blogspot.com/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' proxy-server-free.db | sort | uniq >> ip.db
rm -rf proxy-server-free.db

wget -O vip-socks.db http://www.vip-socks.net/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' vip-socks.db | sort | uniq >> ip.db
rm -rf vip-socks.db

wget -O live-socks.db http://www.live-socks.net/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' live-socks.db | sort | uniq >> ip.db
rm -rf live-socks.db

wget -O socks24.db http://www.socks24.org/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' socks24.db | sort | uniq >> ip.db
rm -rf socks24.db

wget -O socks5list.db http://www.socks5list.com/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' socks5list.db | sort | uniq >> ip.db
rm -rf socks5list.db

wget -O test.db https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=5.36.36.25&port=


wget -O proxies24.db http://www.proxies24.org/feeds/posts/default
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' proxies24.db | sort | uniq >> ip.db
rm -rf proxies24.db

wget -O googlepassedproxies.db http://googlepassedproxies.com/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' googlepassedproxies.db | sort | uniq >> ip.db
rm -rf googlepassedproxies.db

wget -O dan.db https://www.dan.me.uk/torlist/
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' dan.db | sort | uniq >> ip.db
rm -rf dan.db

grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' test.db | sort | uniq >> ip.db
rm -rf test.db

grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ip.db | sort | uniq >> ips.db
rm -rf ip.db