import sys
from functools import reduce
from tokenize import tokenize, untokenize, NUMBER, STRING, NAME, OP
import re
import io
import tokenize

def revlexer(input_file):
    #checking file extension
    extension = input_file[-4:]
    if extension != 'GIAA':
        raise ValueError("Given file extension is not supported!")
    tokens_rev_list = []
    output = ''
    output = output + ' ['
    code = open(input_file, 'r').read()
    tokens_rev_value = tokenize.tokenize(io.BytesIO(code.encode('utf-8')).readline)

if __name__ == "__main__":
    input_file = sys.argv[1]    