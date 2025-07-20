#!/bin/bash


#ffmpeg to take the gas-concentration info and convert it into a movie

cd Outputs/GroundHackedRuns22/GasProduction5/My2OutputPermMultd/Gas_Conc_Overlays

ffmpeg -loglevel panic -y -r 15 -f image2 -s 1920x1080 -start_number 1 -i ./image%d.png -vframes 1000 -vcodec libx264 -crf 10  -pix_fmt yuv420p output_movie.mp4

open output_movie.mp4
