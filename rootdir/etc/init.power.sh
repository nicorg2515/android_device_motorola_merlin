#!/vendor/bin/sh
################################################################################
# helper functions to allow Android init like script
function write() {
    echo -n $2 > $1
}
function copy() {
    cat $1 > $2
}
################################################################################

case $(getprop ro.boot.hwrev) in
0x8130|0x8230)
    is_v3=true
    ;;
*)
    is_v3=false
    ;;
esac

    write /proc/sys/kernel/sched_boost 1

    # HMP scheduler load tracking settings
    write /proc/sys/kernel/sched_window_stats_policy 3
if [ "$is_v3" = true ]
then
    write /proc/sys/kernel/sched_ravg_hist_size 3
    write /proc/sys/kernel/sched_ravg_window 20000000
else
    write /proc/sys/kernel/sched_ravg_hist_size 5
fi

    # HMP Task packing settings for 8939, 8929
    write /proc/sys/kernel/sched_small_task 20
    write /proc/sys/kernel/sched_mostly_idle_load 30
    write /proc/sys/kernel/sched_mostly_idle_nr_run 3

    write /proc/sys/kernel/sched_prefer_idle 0

    write /sys/class/devfreq/cpubw/governor "bw_hwmon"
    write /sys/class/devfreq/cpubw/bw_hwmon/io_percent 20
    write /sys/class/devfreq/gpubw/bw_hwmon/io_percent 40
    write /sys/class/devfreq/mincpubw/governor "cpufreq"

    # disable thermal core_control to update interactive gov settings
    write /sys/module/msm_thermal/core_control/enabled 0

    # enable governor for perf cluster
if [ "$is_v3" = true ]
then
    write /sys/devices/system/cpu/cpu0/online 1
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "interactive"
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay "19000 1113600:39000"
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 85
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 20000
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 1113600
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy 0
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "1 960000:85 1113600:90 1344000:80"
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 40000
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 0
else
    write /sys/devices/system/cpu/cpu0/online 1
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "interactive"
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay "20000 1113600:50000"
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 85
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 20000
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 1113600
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy 0
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "1 960000:85 1113600:90 1344000:80"
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 50000
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 0
fi

    # enable governor for power cluster
if [ "$is_v3" = true ]
then
    write /sys/devices/system/cpu/cpu4/online 1
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor "interactive"
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay "39000 998400:19000"
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 90
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 20000
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 800000
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy 0
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "1 800000:90"
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 40000
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 0
else
    write /sys/devices/system/cpu/cpu4/online 1
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor "interactive"
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay "25000 800000:50000"
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 90
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 40000
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 998400
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy 0
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "1 800000:90"
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 40000
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 0
fi

    # enable thermal core_control now
    write /sys/module/msm_thermal/core_control/enabled 1

    # Bring up all cores online
    write /sys/devices/system/cpu/cpu1/online 1
    write /sys/devices/system/cpu/cpu2/online 1
    write /sys/devices/system/cpu/cpu3/online 1
    write /sys/devices/system/cpu/cpu5/online 1
    write /sys/devices/system/cpu/cpu6/online 1
    write /sys/devices/system/cpu/cpu7/online 1

    # Enable low power modes
    write /sys/module/lpm_levels/parameters/sleep_disabled 0

    # Enable core control
    write /sys/devices/system/cpu/cpu0/core_ctl/min_cpus 0
    write /sys/devices/system/cpu/cpu0/core_ctl/max_cpus 4
    write /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres 68
    write /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres 40
    write /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms 1000
    write /sys/devices/system/cpu/cpu0/core_ctl/task_thres 4
    write /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster 1
    write /sys/devices/system/cpu/cpu4/core_ctl/min_cpus 0
    write /sys/devices/system/cpu/cpu4/core_ctl/max_cpus 4
    write /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres 20
    write /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres 5
    write /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms 3000
    write /sys/devices/system/cpu/cpu4/core_ctl/task_thres 4
    write /sys/devices/system/cpu/cpu4/core_ctl/not_preferred 1

    # HMP scheduler (big.Little cluster related) settings
if [ "$is_v3" = true ]
then
    write /proc/sys/kernel/sched_upmigrate 93
    write /proc/sys/kernel/sched_downmigrate 83
else
    write /proc/sys/kernel/sched_upmigrate 75
    write /proc/sys/kernel/sched_downmigrate 60
fi

if [ "$is_v3" = true ]
then
    # Enable sched guided freq control
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 1
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 1
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load 1
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif 1
    write /proc/sys/kernel/sched_freq_inc_notify 50000
    write /proc/sys/kernel/sched_freq_dec_notify 50000

    # Enable dynamic clock gating
    write /sys/module/lpm_levels/lpm_workarounds/dynamic_clock_gating 1
fi

setprop vendor.post_boot.parsed 1
