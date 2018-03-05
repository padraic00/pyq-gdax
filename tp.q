\p 5000
\P 11i
\l json.k
.z.ws:{queue,:enlist .j.k "[",x,"]"}
queue:()
r:(`$":ws://127.0.0.1:4197")"GET / HTTP/1.1\r\nHost: ws-feed.gdax.com\r\n\r\n"
products::("BTC-USD";"ETH-USD";"ETH-BTC") /,"ETH-BTC","LTC-BTC","LTC-USD")
r[0] .j.j flip `type`product_ids!enlist each("subscribe";products)
h::neg hopen 6000
h"firstTime[]"
s:{{queue::queue where x[;1]>((1!y)each x[;0])`sequence;system"t 1"}[(first each queue)[;(`product_id;`sequence)];x]}
u:{@[{tab::`$".gdax.",ssr[first x`product_id;"-";""]};x;{}];
 $[()~first x;{};
  "open"~first x`type;h(upsert;tab;first each ("G"$x`order_id;"F"$x`price;"F"$x`remaining_size;`$x`side));
  "done"~first x`type;h(!;tab;enlist(=;`order_id;first "G"$x`order_id);0b;`$());
  "received"~first x`type;{};
  "match"~first x`type;{h(upsert;`trade;"jGGSFF*jZ"$'1_value first x);h(!;tab;enlist (=;`order_id;first "G"$x`maker_order_id);0b;(enlist `size)!enlist(-;`size;first "F"$x`size));h(!;tab;enlist(=;`price;0);0b;`$())}[x];
  'change];
 queue::1_queue} /reads queue -  updates book based on type - throws errors for change order (when messge type isn't one of the others)
.z.ts:{@[u;first queue;{errors,:enlist first queue;queue::1_queue}]} / interpret message - catch & append errors - delete from queue

/ Functional delete: (!;tab;enlist(in;`i;(key tab)?(x`maker_order_id))