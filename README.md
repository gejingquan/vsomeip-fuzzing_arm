# vsomeip-fuzzing_arm
1. Create docker image
```
docker build -t vsomeip_fuzzing_arm .
```
2. Create container
```
docker run -it -d --name vsomeip_fuzzing_arm vsomeip_fuzzing_arm
```
3. Enter container
```
docker exec -it vsomeip_fuzzing_arm /bin/bash
```
4. Begin fuzzing
```
afl-fuzz -i input/ -o output/ -Q ./fuzzing @@
```
