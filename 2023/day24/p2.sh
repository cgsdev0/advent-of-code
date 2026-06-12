#!/usr/bin/env bash

# all credit due to https://www.reddit.com/r/adventofcode/comments/18qabia/2023_day_24_part_2_3_am_on_a_christmas_morning/
#
clear
FILE=input.txt

function solve() {
  local -a px py pz vx vy vz cx cy cz
  while IFS=, read ipx ipy ipz ivx ivy ivz; do
    px+=("$ipx")
    py+=("$ipy")
    pz+=("$ipz")
    vx+=("$ivx")
    vy+=("$ivy")
    vz+=("$ivz")
  done
echo "
scale=10;
vax=${vx[0]};
vbx=${vx[1]};
vcx=${vx[2]};
vdx=${vx[3]};
vex=${vx[4]};
pax=${px[0]};
pbx=${px[1]};
pcx=${px[2]};
pdx=${px[3]};
pex=${px[4]};
vay=${vy[0]};
vby=${vy[1]};
vcy=${vy[2]};
vdy=${vy[3]};
vey=${vy[4]};
pay=${py[0]};
pby=${py[1]};
pcy=${py[2]};
pdy=${py[3]};
pey=${py[4]};
        denominator = (((vay - vby) * (pbx - pcx) - (vby - vcy) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vby - vcy) * (pcx - pdx) - (vcy - vdy) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx))) * (((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcx - vdx) * (pdx - pex) - (vdx - vex) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) - (((vby - vcy) * (pcx - pdx) - (vcy - vdy) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcy - vdy) * (pdx - pex) - (vdy - vey) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) * (((vax - vbx) * (pbx - pcx) - (vbx - vcx) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)));

        numerator = (((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)) * (((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pcx - pdx) - ((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pbx - pcx)) - ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) * (((pax*vay - pbx*vby) - (pay*vax - pby*vbx)) * (pbx - pcx) - ((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pax - pbx))) * (((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcx - vdx) * (pdx - pex) - (vdx - vex) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) - (((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) * (((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pdx - pex) - ((pdx*vdy - pex*vey) - (pdy*vdx - pey*vex)) * (pcx - pdx)) - ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) * (((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pcx - pdx) - ((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pbx - pcx))) * (((vax - vbx) * (pbx - pcx) - (vbx - vcx) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)));

      - numerator / denominator
" | bc
echo "
scale=10;
vax=${vy[0]};
vbx=${vy[1]};
vcx=${vy[2]};
vdx=${vy[3]};
vex=${vy[4]};
pax=${py[0]};
pbx=${py[1]};
pcx=${py[2]};
pdx=${py[3]};
pex=${py[4]};
vay=${vz[0]};
vby=${vz[1]};
vcy=${vz[2]};
vdy=${vz[3]};
vey=${vz[4]};
pay=${pz[0]};
pby=${pz[1]};
pcy=${pz[2]};
pdy=${pz[3]};
pey=${pz[4]};
        denominator = (((vay - vby) * (pbx - pcx) - (vby - vcy) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vby - vcy) * (pcx - pdx) - (vcy - vdy) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx))) * (((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcx - vdx) * (pdx - pex) - (vdx - vex) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) - (((vby - vcy) * (pcx - pdx) - (vcy - vdy) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcy - vdy) * (pdx - pex) - (vdy - vey) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) * (((vax - vbx) * (pbx - pcx) - (vbx - vcx) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)));

        numerator = (((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)) * (((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pcx - pdx) - ((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pbx - pcx)) - ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) * (((pax*vay - pbx*vby) - (pay*vax - pby*vbx)) * (pbx - pcx) - ((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pax - pbx))) * (((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcx - vdx) * (pdx - pex) - (vdx - vex) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) - (((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) * (((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pdx - pex) - ((pdx*vdy - pex*vey) - (pdy*vdx - pey*vex)) * (pcx - pdx)) - ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) * (((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pcx - pdx) - ((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pbx - pcx))) * (((vax - vbx) * (pbx - pcx) - (vbx - vcx) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)));

      - numerator / denominator
" | bc
echo "
scale=10;
vax=${vz[0]};
vbx=${vz[1]};
vcx=${vz[2]};
vdx=${vz[3]};
vex=${vz[4]};
pax=${pz[0]};
pbx=${pz[1]};
pcx=${pz[2]};
pdx=${pz[3]};
pex=${pz[4]};
vay=${vx[0]};
vby=${vx[1]};
vcy=${vx[2]};
vdy=${vx[3]};
vey=${vx[4]};
pay=${px[0]};
pby=${px[1]};
pcy=${px[2]};
pdy=${px[3]};
pey=${px[4]};
        denominator = (((vay - vby) * (pbx - pcx) - (vby - vcy) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vby - vcy) * (pcx - pdx) - (vcy - vdy) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx))) * (((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcx - vdx) * (pdx - pex) - (vdx - vex) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) - (((vby - vcy) * (pcx - pdx) - (vcy - vdy) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcy - vdy) * (pdx - pex) - (vdy - vey) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) * (((vax - vbx) * (pbx - pcx) - (vbx - vcx) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)));

        numerator = (((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)) * (((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pcx - pdx) - ((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pbx - pcx)) - ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) * (((pax*vay - pbx*vby) - (pay*vax - pby*vbx)) * (pbx - pcx) - ((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pax - pbx))) * (((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) - ((vcx - vdx) * (pdx - pex) - (vdx - vex) * (pcx - pdx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx))) - (((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) * (((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pdx - pex) - ((pdx*vdy - pex*vey) - (pdy*vdx - pey*vex)) * (pcx - pdx)) - ((pcy-pdy) * (pdx - pex) - (pdy-pey) * (pcx - pdx)) * (((pbx*vby - pcx*vcy) - (pby*vbx - pcy*vcx)) * (pcx - pdx) - ((pcx*vcy - pdx*vdy) - (pcy*vcx - pdy*vdx)) * (pbx - pcx))) * (((vax - vbx) * (pbx - pcx) - (vbx - vcx) * (pax - pbx)) * ((pby-pcy) * (pcx - pdx) - (pcy-pdy) * (pbx - pcx)) - ((vbx - vcx) * (pcx - pdx) - (vcx - vdx) * (pbx - pcx)) * ((pay-pby) * (pbx - pcx) - (pby-pcy) * (pax - pbx)));

      - numerator / denominator
" | bc

}
head -n5 $FILE \
  | tr '@' ',' \
  | tr -d ' ' \
  | solve \
  | paste -sd+ \
  | bc
