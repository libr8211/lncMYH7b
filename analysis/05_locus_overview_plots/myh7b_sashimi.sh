#!/bin/bash


# ./sashimi-plot.py -b input_bams.tsv -c chr10:27040584-27048100 -M 10 -C 3 -O 3 -A median --alpha 1 -F tiff -R 350 --base-size=16 --height=3 --width=18
./sashimi-plot.py -b bamfiles.tsv \
-c chr20:34975253-34985262 \
--gtf gencode.v32.exons.gtf \
-M 3 -C 3 -O 3 -A median \
--alpha 1 -F pdf -R 350 --base-size=16 --height=2 --width=10


./sashimi-plot.py -b bamfiles.tsv \
-c chr20:34980833-34984785 \
-g gencode.v32.exons.gtf \
-M 1 -C 3 -O 3 \
-A median \
--alpha 0.25 \
--base-size=20 --ann-height=4 --height=3 --width=18



-P ggsashimi/examples/palette.txt

