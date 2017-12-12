def aircraft_gen(): 

    """
    Opens a master variable list and writes values to SW equation files.
    This allows for harmonisation of global variables accross all SW equation
    files.
    
    Version history
    v0: Z. Rowland, 07/11/17
    
    Does not allow for eqn. comments as of v0.
    """
    
    input_d = {}
    with open('input_variables.txt','r') as f:                                  # Reads the master variable file
        input_d = dict([line.rstrip('\n').split('\t') for line in f])

    write_new_eqn('master_equations.txt',input_d)
    write_new_eqn('wing\wing_equations.txt',input_d)



def write_new_eqn(filename,input_d):

    """Writes the master variables to a given SW equation file"""

    with open(filename, 'r') as f:                                              # Read the equation file
        eqn_file = f.readlines()

    with open(filename, 'w') as f:                                              # Write to the equation file

        for line in eqn_file:                                                   # Checks all lines in equation file
            for key, value in input_d.items():                                  # ...Against all values in dictionary

                if key in line:                                                 # If the dictionary value is in the file:
                    line = line.split('\t',1)[0]                                # - Cut off the old value
                    line = line+'\t'+value+'\n'                                 # - Replace with the new value

            f.write(line)                                                       # Then write that to the equation file
