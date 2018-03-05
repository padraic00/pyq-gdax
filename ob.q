\p 6000
errors:()
products::("BTC-USD";"ETH-USD";"ETH-BTC") /,"ETH-BTC","LTC-BTC","LTC-USD")
on:([]time:();go:();rev:();eubid:();ebask:();buask:())
epoch:{floor((`long$.z.p)-`long$1970.01.01D00:00)%1e9}
trade:([sym:()]maker_order_id:();taker_order_id:();side:();size:();price:();product_id:();sequence:();time:())
roll:([sym:()]bbo:())
p:{{.j.k raze system "curl -s https://api.gdax.com/products/",x,"/book?level=3"}each products} / fetch current orderbooks
makeBook:{{(eval parse "{.gdax.",ssr[x`product_id;"-";""],"::{1!(flip`order_id`price`size`side!(2 rotate \"FFG\"$flip x`asks),`sell) uj flip`order_id`price`size`side!(2 rotate \"FFG\"$flip x`bids),`buy}(-1)_x}")x}each .p.data}
firstTime:{.p.data::update product_id:products from p[];
 h:hopen 5000;
 makeBook[];
 neg[h](`s;select product_id,sequence from .p.data);
 system "t 1000"} /calls p, makes book, deletes old messages (before sequences in data) from queue
returns:{100*(-1)+(x*y)%z}
gen:{[tab;base]bid::select eff:price*size,meff:(+\)price*size,price,size from `price xdesc select sum size by price from tab where side like "buy";
 ask::select eff:price*size,meff:(+\)price*size,price,size from `price xasc select sum size by price from tab where side like "sell";
 rBid:"f"$$[0=bi:first where bid[`meff]>=base;bid[`price][0];{(((y-sum bid[`eff][til x])*bid[`price][x])%y)+{%[sum bid[`eff][x]*'bid[`price][x];y]}[til x;y]}[bi;base]];
 rAsk:"f"$$[0=ai:first where ask[`meff]>=base;ask[`price][0];{(((y-sum ask[`eff][til x])*ask[`price][x])%y)+{%[sum ask[`eff][x]*'ask[`price][x];y]}[til x;y]}[ai;base]];
 :(rBid;rAsk;rAsk-rBid)}
beu:{btcbid:(gen[.gdax.BTCUSD;1000])[0];
 ebbid:(gen[.gdax.ETHBTC;1000%btcbid])[0];
 ethask:(gen[.gdax.ETHUSD;(1000%btcbid)%ebbid])[1];
 :returns[btcbid;ebbid;ethask]
 }
rev:{ethbid:(gen[.gdax.ETHUSD;1000])[0];
 ebsell:(gen[.gdax.ETHBTC;1000%ethbid])[1];
 btcsell:(gen[.gdax.BTCUSD;ebsell*1000%ethbid])[1];
 :(((btcsell*ebsell*1000%ethbid)-1000)%10;ethbid;ebsell;btcsell) 
 }
.z.ts:{upsert[`on;(epoch[];a[0]>.85;first a;a[1];a[2];last a:rev[])]}