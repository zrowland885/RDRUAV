def aircraft_gen():

    """
    Opens a master variable list and writes values to SW equation files.
    This allows for harmonisation of global variables accross all SW equation
    files.

    Feeds structural values (e.g. mass) back into the assembly to size
    sub-assmeblies (e.g. wings for lift).

    Version history:
    v0: Z. Rowland, 07/11/17
    v1: Z. Rowland, 07/11/17

    To do list:
    - Does not allow for eqn. comments [v0]
    - Mass must be taken manually [v1]
    """

    input_var = read_d('input_variables.txt')                                   # Reads input

    write_new_eqn('master_equations.txt',input_var)                             # Write to equation files
    write_new_eqn('wing\wing_equations.txt',input_var)
    write_new_eqn('fuselage\\fuselage_equations.txt',input_var)


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


def read_d(filename):
    input_d = {}
    with open(filename,'r') as f:                                               # Reads the file
        input_d = dict([line.rstrip('\n').split('\t') for line in f])           # Creates dictionary

    return input_d
