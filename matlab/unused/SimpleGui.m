function [gui_input] = Gui()
%GUI Requests user input via GUI

input_variables = read_dimensions('','input_variables.txt','cell');

prompt = input_variables(1:19,1);
dlg_title = 'Input parameters';
num_lines = 1;
defaultans = input_variables(1:19,2);

gui_ans = inputdlg(prompt,dlg_title,num_lines,defaultans);


gui_ans(end+1) = {0};
gui_ans(end+1) = {0};
gui_ans(end+1) = {0};
gui_ans(end+1) = {0};
gui_ans(end+1) = {0};
gui_ans(end+1) = {0};

gui_input = containers.Map(input_variables(:,1),str2double(gui_ans));

end