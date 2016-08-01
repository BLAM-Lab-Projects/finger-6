function out = ConvertByte(mat)
% Convert vector of bytes from the serial port to a 3xN matrix, N being
% num_sensors + 1 (1 for the timestamp in microseconds)
% Strong assumption: Timestamp is 4 bytes, each of the sensors is two
    time_indices = 1:(4 + 4):length(mat); %add 3 to get end indices
    sensor1_indices = 5:(4 + 4):length(mat); % add 1 to get end indices
    sensor2_indices = 7:(4 + 4):length(mat); % *

    times = mat([time_indices; time_indices+1; time_indices+2; time_indices+3]);
    sensor1 = mat([sensor1_indices; sensor1_indices + 1]);
    sensor2 = mat([sensor2_indices; sensor2_indices + 1]);

    times = typecast(uint8(times), 'uint32');
    sensor1 = typecast(uint8(sensor1), 'uint16');
    sensor2 = typecast(uint8(sensor2), 'uint16');
    out = [times, sensor1, sensor2];

end
