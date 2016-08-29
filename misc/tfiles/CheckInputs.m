function opts = CheckInputs(opts, varargin)
% all credit to 
% http://stackoverflow.com/questions/2775263/how-to-deal-with-name-value-pairs-of-function-arguments-in-matlab

%# read the acceptable names
opt_names = fieldnames(opts);

%# count arguments
num_args = length(varargin);
if round(num_args/2) ~= num_args/2
   error('FUNCTION needs propertyName/propertyValue pairs')
end

for pair = reshape(varargin, 2, []) %# pair is {propName;propValue}
   input_name = lower(pair{1}); %# make case insensitive
   if any(strcmp(input_name, opt_names))
      %# overwrite opts. If you want you can test for the right class here
      %# Also, if you find out that there is an option you keep getting wrong,
      %# you can use "if strcmp(input_name, 'problemOption'),testMore,end"-statements
      opts.(input_name) = pair{2};
   else
      error('%s is not a recognized parameter name', input_name)
   end
end