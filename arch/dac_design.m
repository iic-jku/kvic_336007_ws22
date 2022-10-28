disp('--------------------------------------------');
disp('DAC Analyzer (c) 2021 Harald Pretl, IIC, JKU');
disp('--------------------------------------------');
disp('');
pkg load signal; % for `rms`, 'interp` and `decimate`
clear;

% name of audio tracks
% --------------------
audio_file_in  = 'testaudio.wav';
audio_file_out = 'testaudio_out.wav';

% parameters
% ----------
n = 16;
% no of bits; we represent data as unsigned integer
osr = 128;
% oversampling ratio of delta-sigma
interp_method = 1;
% 0 = zero insertion
% 1 = zero-order hold
% 2 = first-order hold [not implemented]
% 3 = interpolation with sinc
sd_type = 2;
% 1 = first-order modulator
% 2 = second-order modulator
use_sine = false;
% select if sine or audio used for testing

% read test audio file, is signed .wav (+1...-1)
% ----------------------------------------------
if use_sine == false
  disp(strcat('Step 1: Read audio file, filename=',audio_file_in));
  [track_in, fs_audio] = audioread(audio_file_in);
  track_in = track_in';
else
  disp('Step 1: Generate 441Hz sine tone with 60% fullscale');
  fs_audio = 44100;
  t_sin = (0:fs_audio-1)/fs_audio;
    track_in = 0.6 * sin(2*pi * 441 * t_sin);
  end % if 
  
disp(strcat('Info: fs=',num2str(fs_audio),'Hz'))
% remove dc
track_in = track_in - mean(track_in);
% scale track (signed float to unsigned int by adding offset)
u = round((track_in+1)*2^(n-1));

% derived parameters
fullscale = 2^n;
fs_out = fs_audio * osr; % Hz

% upsample by osr, insertion of zeros
% -----------------------------------
if (interp_method == 0)
  % interpolation by inserting zeros
  u_samples = length(u);
  u_up = zeros(1,u_samples*osr);
  u_up(osr*(1:u_samples)) = u;
elseif (interp_method == 1)
  % interpolation by zero-order hold
  u_up = repelem(u,osr);
elseif (interp_method == 2)
  % interpolation by first-order hold
  % FIXME
elseif (interp_method == 3)
  % interpolation by sinc
  u_up = interp(u,osr);
end % if

% delta-sigma core
% ----------------
no_samples = length(u_up);
progress_step=round(no_samples/10);
reg1 = 0; reg2 = 0; reg3 = 0; c1 = 0;
out_sd = zeros(1,no_samples);

disp('Step 2: Perform delta-sigma processing...');

if (sd_type == 1) % first order modulator
  for i=1:no_samples
    % print a progress bar
    if (rem(i,progress_step) == 0)
      disp(strcat('  ',num2str(round(i/no_samples*100)),'%'));
    end % if
    
    out = u_up(i) + reg1; % 17b UINT
    reg1 = mod(out,fullscale); % 16b UINT; cut off MSB and store
    out_sd(i) = fix(out / fullscale); % 1b; MSB is output bit
  end % for
end % if

if (sd_type == 2) % second order modulator
  for i=1:no_samples
    % print a progress bar
    if (rem(i,progress_step) == 0)
      disp(strcat('  ',num2str(round(i/no_samples*100)),'%'));
    end % if

    if (mod(i,4) == 0) ; % first modulator runs on fs/4
      out1 = u_up(i) + 2*reg1 + (fullscale - reg2); % 18b UINT
      reg2 = reg1; % 16b UINT; reg2 = reg1 * z^-1
      reg1 = mod(out1,fullscale); % 16b UINT; cut off MSB/MSB-1 and store
      c1 = fix(out1 / fullscale); % 2b UINT; MSB/MSB-1 is output bits
    end % if
    out2 = c1 + reg3; % 3b UINT
    reg3 = mod(out2,4); % 2b UINT; cut off MSB and store   
    out_sd(i) = fix(out2 / 4); % 1b; MSB is output bit
  end % for
end % if

disp('...done');

% decimate audio for playback, and scale according to input
% ---------------------------------------------------------
% we use a halfband filter approach to decimate
filt1 = fir1(osr, 1/osr);
filt2 = fir1(osr/4, 4/osr);
temp1 = fftfilt(filt1, out_sd);
temp2 = temp1(1:2:length(temp1));
temp3 = fftfilt(filt1, temp2);
temp4 = temp3(1:2:length(temp3));
temp5 = fftfilt(filt2, temp4);
out_sd_dec = temp5(1:(osr/4):length(temp5));
% now get back to audio track format
track_out = (out_sd_dec - mean(out_sd_dec)); % remove dc
track_out = track_out * rms(track_in)/rms(track_out); % balance looudness
track_out = min(0.999,track_out); % clip max
track_out = max(-0.999,track_out); % clip min
track_out = track_out * rms(track_in)/rms(track_out); % balance after clip

% write resulting audio track
% ---------------------------
disp(strcat('Step 3: Write audio file, filename=',audio_file_out));
audiowrite(audio_file_out,track_out',fs_audio);

% calculate SNR
% -------------
track_out(1:length(track_out)-1) = track_out(2:length(track_out));
sqnr_sd = 20*log10(rms(track_out)/rms(track_in-track_out));
disp(strcat('Info: SQNR=',num2str(sqnr_sd),'dB'));

% byebye
disp('');
disp('Done, bye!');
