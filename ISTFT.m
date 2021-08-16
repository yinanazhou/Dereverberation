function y = ISTFT(S, win, win_sz, noverlap, y_len)

y = zeros(y_len, 1);

% window_size = length(window);
[freqlen, framelen] = size(S);
hop_size = win_sz - noverlap;

% pad M-1 zeros
% S(freqlen+1:win_sz, :) = zeros(win_sz-freqlen, framelen);
S(freqlen+1:win_sz, :) = conj(flipud(S(1:freqlen-2, :)));

for FrameIdx = 1:framelen
   StartIdx = (FrameIdx -1)*hop_size;
   EndIdx = StartIdx + win_sz;
   if StartIdx + win_sz > y_len
       break
   end
   NewFrame = win.*ifft(S(:, FrameIdx), 'symmetric');
   y(StartIdx+1:EndIdx) = y(StartIdx+1:EndIdx) + NewFrame;
end
    
end