-module(get_put).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

-define(HARNESS, (rt_config:get(rt_harness))).

confirm() ->
    lager:info("entering get_put:confirm()"),
    HostList = rt_config:get(rt_hostnames),
    Count = length(HostList),

    _Config = rtperf:standard_config(Count),

    [Nodes] = rt:build_clusters([Count]),
    lager:info("Built cluster: ~p", [Nodes]),

    BinSize = rt_config:get(perf_bin_size),
    SetSize = rtperf:target_size(rt_config:get(perf_target_pct),
                                 BinSize,
                                 rt_config:get(perf_ram_size),
                                 Count),

    TestConfig =
        rt_bench:config(
          max,
          rt_config:get(perf_duration),
          HostList,
          {int_to_bin_bigendian, {truncated_pareto_int, SetSize}},
          rt_bench:valgen(rt_config:get(perf_bin_type), BinSize),
          %% 4:1 get/put
          [{get, 3}, {update, 1}]
         ),

     ok = rtperf:maybe_prepop(Nodes, BinSize, SetSize),

     ok = rtperf:run_test(Nodes, TestConfig, []),
     pass.
