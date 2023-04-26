import sys
def revlexer(input_file):
    #checking file extension
    extension = input_file[-3:]
    if extension != '.rev':
        raise ValueError("Given file extension is not supported!")

if __name__ == "__main__":
    input_file = sys.argv[1]    