function [out, headers, data] = ParseTgt(filename, delim)
% filename must be the full (relative) path to the .tgt file 
% also assumes comma-delimited.
% This is essentially a poor man's readtable
	fid = fopen(filename, 'r');
	headerline = fgetl(fid);
	data = dlmread(filename, delim, 1, 0);
	fclose(fid);

	headers = textscan(headerline,'%s','Delimiter', delim);
	headers = headers{1};
	
	for ii = 1:length(headers)
	    out.(headers{ii}) = data(:, ii);
	end
	
	headers = sprintf('%s,' , headers{:});
	headers = headers(1:end-1);
end