cd /home/runner
export PATH=/usr/bin:/bin:/tool/pandora64/bin:/usr/local/bin
export HOME=/home/runner
iverilog '-Wall' '-g2012' design.sv testbench.sv  && unbuffer vvp a.out  ; echo 'Creating result.zip...' && zip -r /tmp/tmp_zip_file_123play.zip . && mv /tmp/tmp_zip_file_123play.zip result.zip