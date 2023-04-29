import sys
from tokenize import tokenize
import io
import tokenize

def revlexer(input_file):
    #checking file extension
    extension = input_file[-4:]
    if extension != '.rev':
        raise ValueError("Given file extension is not supported!")
    tokens_rev_list = []
    output = ''
    output = output + ' ['
    code = open(input_file, 'r').read()
    tokens_rev_value = tokenize.tokenize(io.BytesIO(code.encode('utf-8')).readline)
    for i in tokens_rev_value:
        token_rev_value = i[1]
        revtoklen = len(token_rev_value)
        revflag1 = (token_rev_value != "\t"  and token_rev_value != "\n")
        revflag2 = (token_rev_value != '"' and token_rev_value != "utf-8")
        revflag  = revflag1 and revflag2

        revoepnbraceflag = token_rev_value == ')' or token_rev_value == '('
        revflowerbraceflag =  token_rev_value == '{' or token_rev_value == '}'
        revbraceflag = revoepnbraceflag or revflowerbraceflag        

        if revtoklen!= 0:
            if revflag:
                if token_rev_value == '[':
                    tokens_rev_list.append(token_rev_value)                  
                    continue
                elif token_rev_value == ']':
                    tokens_rev_list.append(token_rev_value)
                    output = output +  ("".join(tokens_rev_list))
                    tokens_rev_list = []    
                else:
                    if token_rev_value[:1] == '"':
                        t = token_rev_value[1:-1]
                        print(t)
                        output = output + "'" + '"' + "'" + ',' + "'"
                        output = output + t
                        output = output + "'" + ',' + "'" + '"' + "'"


                    elif revbraceflag:
                        output  = output +  "'" 
                        output = output + token_rev_value 
                        output = output + "'"

                    elif token_rev_value == '!=':
                        output = output +  "'"
                        output = output + token_rev_value
                        output = output + "'"

                    else:
                        output = output +  token_rev_value
                output = output +  ","
    output = output[:-1]
    output = output +  " ]"
    print(output)
    
    return output
    
if __name__ == "__main__":

    input_file = sys.argv[1]
    tokens = revlexer(input_file)   
