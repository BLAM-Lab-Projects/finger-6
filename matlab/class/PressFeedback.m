classdef PressFeedback < Rectangle & Rainbow

    properties
        current_vals; % 1xN vector
        current_fill;
        default_fill;
        current_frame;
        default_frame;
    end

    methods
        function self = PressFeedback(len, varargin)
            self = self@Rectangle(varargin{:});
            self.current_vals = zeros(1, len);

            self.default_fill = repmat(self.fill_color, len, 1)';
            self.current_fill = self.default_fill;
            self.default_frame = repmat(self.frame_color, len, 1)';
            self.current_frame = self.default_frame;
        end

        function Fill(self, index, color)
            self.current_fill(:, index) = self.(color);
        end

        function Frame(self, index, color)
            self.current_frame(:, index) = self.(color);
        end

        function Clear(self)
            self.current_fill = self.default_fill;
            self.current_frame = self.default_frame;
        end
    end

end
