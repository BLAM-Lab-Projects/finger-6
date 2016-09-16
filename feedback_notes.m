feedback = PobRectangle();

feedback.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.3, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255]);

feedback.Register(win.pointer);
feedback.Prime();

feedback.Set(1, 'frame_color', [255, 30, 63]); %red
feedback.Set(1, 'frame_color', [97, 255, 77]); % green
feedback.Set(1, 'frame_color', [190 190 190]); % gray

feedback.Draw(1);
