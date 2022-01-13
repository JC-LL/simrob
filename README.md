# simrob
Simple "Robot" simulator


The prototype is built upon *Graphics*, a gem made for simple animations.

```
gem install graphics
```

Some dependencies may require to install very well supported librairies on Linux (SDL ,etc).

To run the simulator parameterized with a dummy *scenario* (plain Ruby hash) type :

```
./bin/simrob -s tests/scenario_0.sno
```
Each Robot has an attached VM/ISS/Processor that can be booted with :

```
./bin/simrob -s tests/scenario_0.sno --boot_vms
```
