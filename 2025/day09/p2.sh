#!/bin/bash

FILE="$1"

declare -A grid
make_a_grid_DEBUG_ONLY_NOT_FOR_PROD() {
  local a b c d color
  local cur
  local w=0
  local h=0
  local bx by sx sy ax ay
  while read a b c d color; do
    IFS=, read x y <<< "$b"
    IFS=, read x2 y2 <<< "$c"
    if [[ x -ge w ]]; then
      w=$((x+1))
    fi
    if [[ y -ge h ]]; then
      h=$((y+1))
    fi
    bx=$((x>x2?x:x2))
    sx=$((x<x2?x:x2))
    by=$((y>y2?y:y2))
    sy=$((y<y2?y:y2))
    before=${grid[$x2,$y2]}
    for((ay=$sy;ay<=by;ay++)); do
      for((ax=$sx;ax<=bx;ax++)); do
        grid[$ax,$ay]='XX'
      done
    done
    grid[$x,$y]="\e[${color}m$d\e[39m"
    grid[$x2,$y2]=$before
  done
  for ((y=0;y<=h;y++)); do
    for ((x=0;x<=w;x++)); do
      c="${grid[$x,$y]}"
      c=${c:-..}
      echo -ne "$c"
    done
    echo
  done
}

wahoo() {
  local first second line
  while IFS= read -r line; do
    echo $line
    if [[ -z "$first" ]]; then
      first="$line"
    elif [[ -z "$second" ]]; then
      second="$line"
    fi
  done
  echo $first
  echo $second
}

yeehaw() {
  local x y
  while IFS=, read x y; do
    echo "$((12-x)),$((10-y))"
  done
}

enterprise_func() {
  local next_x next_y
  local prev_x
  local prev_y
  local curr_x
  local curr_y
  while IFS=, read next_x next_y; do
    if [[ -z $prev_x ]]; then
      prev_x=$next_x
      prev_y=$next_y
      continue
    fi
    if [[ -z $curr_x ]]; then
      curr_x=$next_x
      curr_y=$next_y
      continue
    fi
    echo -n "$prev_x,$prev_y $curr_x,$curr_y $next_x,$next_y "
    [[ curr_x -gt prev_x ]] && P=L
    [[ curr_x -lt prev_x ]] && P=R
    [[ curr_y -lt prev_y ]] && P=U
    [[ curr_y -gt prev_y ]] && P=D
    [[ curr_x -gt next_x ]] && N=L
    [[ curr_x -lt next_x ]] && N=R
    [[ curr_y -lt next_y ]] && N=U
    [[ curr_y -gt next_y ]] && N=D

    echo -n "$P$N"

    case "$P$N" in
      RU|UL|DR|LD)
        # red time
        echo -n " 31"
        ;;
      DL|LU|UR|RD)
        # blue time
        echo -n " 34"
        ;;
    esac

    echo
    prev_x=$curr_x
    prev_y=$curr_y
    curr_x=$next_x
    curr_y=$next_y
  done
}

# cat "$FILE" \
#   | wahoo \
#   | enterprise_func \
#   | make_a_grid_DEBUG_ONLY_NOT_FOR_PROD

mapfile -t edges< <(cat "$FILE" \
  | wahoo \
  | enterprise_func \
  | cut -d' ' -f2,3 \
  | tr , \ )

# FILE=input.txt
mapfile -t points< <(cat "$FILE" \
  | wahoo \
  | enterprise_func \
  | cut -d' ' -f2,4,5 \
  | tr , \ )

edges_cross() {
  local k=$1
  local lx1=$2
  local ly1=$3
  local lx2=$4
  local ly2=$5
  local x1 x2 y1 y2
  local bx by sx sy
  read x1 y1 x2 y2 <<< "${edges[k]}"
  # parallel vertical
  if ((x1==x2&&lx1==lx2)); then
    return 1
  fi
  # parallel horizontal
  if ((y1==y2&&ly1==ly2)); then
    return 1
  fi
  # vertical case
  if ((x1==x2)); then
    bx=$((lx1>lx2?lx1:lx2))
    sx=$((lx1<lx2?lx1:lx2))
    by=$((y1>y2?y1:y2))
    sy=$((y1<y2?y1:y2))
    if((x1>sx&&x1<bx&&ly1<by&&ly1>sy)); then
      return 0
    fi
  fi
  # vertical case
  if ((y1==y2)); then
    by=$((ly1>ly2?ly1:ly2))
    sy=$((ly1<ly2?ly1:ly2))
    bx=$((x1>x2?x1:x2))
    sx=$((x1<x2?x1:x2))
    if((y1>sy&&y1<by&&lx1<bx&&lx1>sx)); then
      return 0
    fi
  fi
  return 1
}
count=${#points[@]}
max=0
for ((i=0; i<count; ++i)); do
  echo "Progress: $i / $count" 1>&2
  for ((j=i+1; j<count; ++j)); do
    [[ i -eq j ]] && continue
    read a b c d <<< "${points[i]}"
    read e f g h <<< "${points[j]}"
    case "$c" in
      LD) ((a>e&&b>f))&&continue ;;
      UL) ((a>e&&b<f))&&continue ;;
      DR) ((e>a&&b>f))&&continue ;;
      RU) ((e>a&&b<f))&&continue ;;
      UR) ((e>=a&&f>=b))||continue ;;
      LU) ((e<=a&&f>=b))||continue ;;
      RD) ((e>=a&&f<=b))||continue ;;
      DL) ((e<=a&&f<=b))||continue ;;
    esac
    case "$g" in
      LD) ((e>a&&f>b))&&continue ;;
      UL) ((e>a&&f<b))&&continue ;;
      DR) ((a>e&&f>b))&&continue ;;
      RU) ((a>e&&f<b))&&continue ;;
      UR) ((a>=e&&b>=f))||continue ;;
      LU) ((a<=e&&b>=f))||continue ;;
      RD) ((a>=e&&b<=f))||continue ;;
      DL) ((a<=e&&b<=f))||continue ;;
    esac
    bx=$((a>e?a:e))
    sx=$((a<e?a:e))
    by=$((b>f?b:f))
    sy=$((b<f?b:f))
    dx=$((bx-sx))
    dy=$((by-sy))
    area=$(((dx + 1)*(dy + 1)))
    [[ area -le max ]] && continue
    candidate=1
    for ((k=0; k<count; ++k)); do
      [[ i -eq k ]] && continue
      [[ j -eq k ]] && continue
      read kx ky kc kd <<< "${points[k]}"
      if ((kx>sx&&kx<bx&&ky>sy&&ky<by)); then
        candidate=0
        break
      fi
      if ((kd==34&&((sx==kx||bx==kx)&&(ky<by&&ky>sy)))); then
        candidate=0
        break
      fi
      if ((kd==34&&((sy==ky||by==ky)&&(kx<bx&&kx>sx)))); then
        candidate=0
        break
      fi
      edges_cross $k $sx $sy $bx $sy && candidate=0 && break
      edges_cross $k $bx $sy $bx $by && candidate=0 && break
      edges_cross $k $bx $by $sx $by && candidate=0 && break
      edges_cross $k $sx $by $sx $sy && candidate=0 && break
    done
    if [[ candidate -eq 1 ]]; then
      echo "$a,$b,$c -> $e,$f,$g ($area)" 1>&2
      max=$area
    fi
  done
done

echo $max
