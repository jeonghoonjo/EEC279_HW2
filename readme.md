# EEC279-F22 Assignment 2

Compile with 
```sell
nvcc -std=c++17 main.cu -o app
```

Execute the app with cli arguments to read in the matrices

```shell
./app test_data1/a test_data1/b
```

A python script has been provided `matrix.py` to generate matrices that can be read by
the app. Make sure to change the precision format specifier in print_matrix to view more
decimal places. To generate a 4x4 matrix and save it to file `mat_a`,

```
python matrix.py 4 4 mat_a
```


