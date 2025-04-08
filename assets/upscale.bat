for /F %%x in ('dir /B/D 1x') do magick 1x\%%x -filter point -scale 200%% 2x\%%x
