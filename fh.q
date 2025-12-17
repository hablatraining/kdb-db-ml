system"l sim.q";
system"l stat.q";

.fh.tp:neg hopen `$":",first .z.x;
.fh.n:count .fh.ids:enlist `USDEUR;
.fh.t:raze .sim.genp[;;;;.z.t]'[.fh.ids;enlist 1.17;.fh.s:.fh.n?1f;.fh.r:.fh.n?.01];

.z.ts:{[x]
  t:(`id xkey .fh.t)@/:.fh.ids;
  .fh.t:`time xcols raze -1#'.sim.genp[;;;;first[t`time],.z.t]'[.fh.ids;t`price;.fh.s;.fh.r];
  .fh.tp(".u.upd";`trade;1_value flip .fh.t)
    };

\t 10