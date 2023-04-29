# REV Programming Language
# SER 502 Spring 2023 - Team 22

## System on which our compiler and runtime are built
- Windows

## Tools Used
- Python
- SWI-Prolog


## Directions to install and run Rev language
- Clone this github repository into your machine.
- Install the above mentioned tools(Python and SWI-Prolog)
- Now open command prompt in the folder "SER502-Spring2023-Team22"
- Now execute the below command in the command prompt:


```
swipl
```
- Now give the path to the .pl file for compilation:
```
['path of rev.pl file.'].
```
- In our case the command is:
```
['src/rev.pl'].
```
- Now to run a sample program, we need to execute the following command:
```
rev('path of revLexer.py file','path of the input program file').
```
In our case all the sample programs are present in data folder. To run the program "arithmetic.rev", the follwoing command should be entered:
```
rev('src/revLexer.py','data/arithmetic.rev').
```
## Project Video Link

- Youtube Video Link -

