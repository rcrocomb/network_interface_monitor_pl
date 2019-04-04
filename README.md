<pre>
$ ./s.pl
Adaptive units: yes
Looking at stats for interface 'eth0'
2019-04-03 23:45:48 Tx    0.000 kbps Rx    0.000 kbps
2019-04-03 23:45:50 Tx  770.000  Bps Rx   16.750 kBps
2019-04-03 23:45:52 Tx  700.000  Bps Rx   17.048 kBps
^CRan for 5 seconds
Transmitted 2940 bytes (2.94e-06 GB) in total
Received 67597 bytes (6.7597e-05 GB) in total
Average Tx bandwidth: 588.000 bytes/sec
Average Rx bandwidth: 13519.400 bytes/sec
$

--------------------------------------------------------------------------------
OR
--------------------------------------------------------------------------------

$ ./s.pl  --no-units
Adaptive units: no
Looking at stats for interface 'eth0'
2019-04-03 23:46:01	           0	           0
^CRan for 1 seconds
Transmitted 0 bytes (0 GB) in total
Received 0 bytes (0 GB) in total
Average Tx bandwidth: 0.000 bytes/sec
Average Rx bandwidth: 0.000 bytes/sec
$

--------------------------------------------------------------------------------
OR
--------------------------------------------------------------------------------

$ ./s.pl  --no-units lo
Adaptive units: no
Looking at stats for interface 'lo'
2019-04-03 23:46:13	           0	           0
^CRan for 2 seconds
Transmitted 0 bytes (0 GB) in total
Received 0 bytes (0 GB) in total
Average Tx bandwidth: 0.000 bytes/sec
Average Rx bandwidth: 0.000 bytes/sec
$
</pre>

